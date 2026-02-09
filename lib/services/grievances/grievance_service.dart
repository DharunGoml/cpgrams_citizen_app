import 'package:cpgrams_citizen_app/models/api_response.dart';
import 'package:cpgrams_citizen_app/models/grievances/grievance_modal.dart';
import 'package:cpgrams_citizen_app/network/api_headers.dart';
import 'package:cpgrams_citizen_app/network/dio_client.dart';
import 'package:cpgrams_citizen_app/utils/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GrievanceService {
  static Future<String?> get accessToken => SecureStorage.accessToken;

  Future<ApiResponse<Map<String, dynamic>>> pdfExtract(
    FormData formData,
  ) async {
    try {
      // Get stored tokens from secure storage
      final kAccessToken = await SecureStorage.accessToken ?? '';
      final kGuestId = await SecureStorage.guestId ?? '';

      if (kAccessToken.isEmpty || kGuestId.isEmpty) {
        return ApiResponse.failure(
          message: 'Authentication required. Please login first.',
        );
      }

      /// 1️⃣ Upload PDF
      final uploadHeaders = ApiHeaders.build(
        sourceId: 'citizen.web',
        clientId: 'darpg-guest',
        enableAuth: true,
        accessToken: kAccessToken,
        guestId: kGuestId,
      );

      final uploadResp = await DioClient.dio.post(
        '/grievances/api/v1/files',
        data: formData,
        options: Options(headers: uploadHeaders),
      );

      final uploadData = uploadResp.data;

      /// 2️⃣ Extract fileId safely with multiple fallback checks
      String? fileId;
      String? fileUrl;

      try {
        final data = uploadData['data'] ?? uploadData;

        if (data is List && data.isNotEmpty) {
          final first = data.first;
          fileId =
              first['fileId'] ??
              first['file_id'] ??
              first['id'] ??
              first['fileID'];
          fileUrl =
              first['fileUrl'] ??
              first['file_url'] ??
              first['fileUrlWithQuery'] ??
              first['file_url_with_query'] ??
              first['filePath'] ??
              first['path'];
        } else if (data is Map) {
          fileId =
              data['fileId'] ?? data['file_id'] ?? data['id'] ?? data['fileID'];
          fileUrl =
              data['fileUrl'] ??
              data['file_url'] ??
              data['file_url_with_query'] ??
              data['fileUrlWithQuery'] ??
              data['filePath'] ??
              data['path'];
        }

        // Top-level fallback checks
        fileId ??=
            uploadData['fileId'] ?? uploadData['file_id'] ?? uploadData['id'];
        fileUrl ??= uploadData['fileUrl'] ?? uploadData['file_url'];
      } catch (e) {
        debugPrint('[GrievanceService] Error parsing upload response: $e');
      }

      if (fileId == null) {
        debugPrint(
          '[GrievanceService] Could not determine fileId from response',
        );
        return ApiResponse.failure(
          message: 'File uploaded but could not find fileId in response',
        );
      }

      debugPrint(
        '[GrievanceService] Extracted fileId: $fileId, fileUrl: $fileUrl',
      );

      /// 3️⃣ Call OCR API with extracted fileId
      final ocrPayload = {'file_id': fileId, 'guest_id': kGuestId};
      debugPrint('[GrievanceService] OCR Payload: $ocrPayload');

      final kOcrApiUrl = dotenv.env['OCR_API_URL'] ?? '';
      final ocrResp = await DioClient.dio.post(
        kOcrApiUrl,
        data: ocrPayload,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $kAccessToken',
          },
        ),
      );

      debugPrint(
        '[GrievanceService] OCR response status: ${ocrResp.statusCode}',
      );

      /// 4️⃣ Success - return combined result matching Next.js structure
      final combinedResult = {
        'ok': true,
        'uploaded': uploadData,
        'fileId': fileId,
        'fileUrl': fileUrl,
        'ocr': ocrResp.data,
        'meta': {
          'filesEndpoint': '/grievances/api/v1/files',
          'ocrEndpoint': kOcrApiUrl,
          'forwardedAuth': true,
        },
      };

      return ApiResponse.success(
        data: combinedResult,
        message: 'PDF extracted successfully',
      );
    } on DioException catch (e) {
      final errorData = e.response?.data;
      debugPrint(
        '[GrievanceService] DioException [${e.response?.statusCode}]: ${e.message}',
      );
      debugPrint('[GrievanceService] Error data: $errorData');

      return ApiResponse.failure(
        message:
            errorData?['message'] ??
            errorData?.toString() ??
            e.message ??
            'Network error',
      );
    } catch (e) {
      debugPrint('[GrievanceService] Unexpected error: $e');
      return ApiResponse.failure(
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getGrievanceTrackList(
    GrievanceListModal payload,
  ) async {
    final accessToken = await SecureStorage.accessToken ?? "";
    try {
      final response = await DioClient.dio.post(
        "/grievances/api/v1/list",
        data: payload.toJson(),
        options: Options(
          headers: ApiHeaders.build(
            sourceId: "citizen.web",
            clientId: "darpg",
            enableProtectedAuth: true,
            accessToken: accessToken,
          ),
        ),
      );
      return ApiResponse.success(
        data: response.data?['data'],
        message: 'Grievance track list fetched successfully',
      );
    } on DioException catch (e) {
      String errorMessage = 'An error occurred during Verifying OTP';
      if (e.response?.data?['errors'] != null) {
        final errors = e.response!.data['errors'];
        if (errors is List && errors.isNotEmpty) {
          errorMessage = errors[0]['message'] ?? errorMessage;
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      return ApiResponse.failure(message: errorMessage);
    } catch (e) {
      return ApiResponse.failure(
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }
}
