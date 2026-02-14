import 'dart:convert';

import 'package:cpgrams_citizen_app/models/api_response.dart';
import 'package:cpgrams_citizen_app/models/auth/otp_modal.dart';
import 'package:cpgrams_citizen_app/models/grievances/draft_modal.dart';
import 'package:cpgrams_citizen_app/models/grievances/grievance_modal.dart';
import 'package:cpgrams_citizen_app/network/api_headers.dart';
import 'package:cpgrams_citizen_app/network/dio_client.dart';
import 'package:cpgrams_citizen_app/utils/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GrievanceService {
  static Future<String?> get accessToken => SecureStorage.accessToken;

  String _extractErrorMessage(dynamic errorData, String defaultMessage) {
    if (errorData is! Map) return defaultMessage;

    return errorData['message']?.toString() ??
        errorData['error']?.toString() ??
        defaultMessage;
  }

  Future<ApiResponse<Map<String, dynamic>>> pdfExtract(
    FormData formData,
    bool? isAuthRequired,
  ) async {
    try {
      final kAccessToken = await SecureStorage.accessToken ?? '';
      final kGuestId = await SecureStorage.guestId ?? '';

      if (isAuthRequired == true && kAccessToken.isEmpty) {
        return ApiResponse.failure(
          message: 'Authentication required. Please login first.',
        );
      }

      if (isAuthRequired != true &&
          (kAccessToken.isEmpty || kGuestId.isEmpty)) {
        return ApiResponse.failure(
          message: 'Authentication required. Please login first.',
        );
      }

      final uploadHeaders = ApiHeaders.build(
        sourceId: 'citizen.web',
        clientId: isAuthRequired == true ? 'darpg' : 'darpg-guest',
        enableProtectedAuth: isAuthRequired == true,
        enableAuth: isAuthRequired != true,
        accessToken: kAccessToken,
        guestId: kGuestId,
      );

      final uploadResp = await DioClient.dio.post(
        '/common/api/v1/files/upload',
        data: formData,
        options: Options(headers: uploadHeaders),
      );

      final uploadData = uploadResp.data;

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

        fileId ??=
            uploadData['fileId'] ?? uploadData['file_id'] ?? uploadData['id'];
        fileUrl ??= uploadData['fileUrl'] ?? uploadData['file_url'];
      } catch (e) {
        debugPrint('[GrievanceService] Error parsing upload response: $e');
      }

      if (fileId == null) {
        return ApiResponse.failure(
          message: 'File uploaded but could not find fileId in response',
        );
      }

      final ocrPayload = {
        'file_id': fileId,
        if (kGuestId.isNotEmpty) 'guest_id': kGuestId,
      };

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

      final combinedResult = {
        'ok': true,
        'uploaded': uploadData,
        'fileId': fileId,
        'fileUrl': fileUrl,
        'ocr': ocrResp.data,
        'meta': {
          'filesEndpoint': '/common/api/v1/files/upload',
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
      String errorMessage = 'Network error';

      if (errorData != null && errorData is Map) {
        if (errorData['detail'] != null && errorData['detail'] is Map) {
          errorMessage = errorData['detail']['message'] ?? errorMessage;
        } else if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        } else if (errorData['error'] != null) {
          errorMessage = errorData['error'].toString();
        }
      }

      errorMessage = errorMessage == 'Network error'
          ? (e.message ?? errorMessage)
          : errorMessage;

      return ApiResponse.failure(message: errorMessage);
    } catch (e) {
      debugPrint('[GrievanceService] Unexpected error: $e');
      return ApiResponse.failure(
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> sendOtp(
    Map<String, dynamic> payload,
  ) async {
    try {
      final transactionId = DateTime.now().millisecondsSinceEpoch.toString();
      final timestamp = DateTime.now().toUtc().toIso8601String();

      final headers = {
        'x-source-id': dotenv.env['OTP_X_SOURCE_ID'] ?? 'citizen.web',
        'x-client-id': dotenv.env['OTP_X_CLIENT_ID'] ?? 'darpg',
        'x-transaction-id': transactionId,
        'x-api-client-version': '1.0.1',
        'x-request-timestamp': timestamp,
        'x-api-resource': '/users/api/v1/otp/send',
        'Content-Type': 'application/json',
      };

      final apiKey = dotenv.env['OTP_BACKEND_API_KEY'];
      if (apiKey != null && apiKey.isNotEmpty) {
        headers['x-api-key'] = apiKey;
      }

      final response = await DioClient.dio.post(
        '/users/api/v1/otp/send',
        data: payload,
        options: Options(headers: headers, validateStatus: (status) => true),
      );
      if (response.statusCode != null && response.statusCode! >= 400) {
        final errorData = response.data;
        String errorMessage = 'Failed to send OTP';

        if (errorData is Map) {
          errorMessage =
              errorData['error']?.toString() ??
              errorData['message']?.toString() ??
              errorMessage;
        }

        return ApiResponse.failure(message: errorMessage);
      }

      return ApiResponse.success(
        data: response.data is Map<String, dynamic>
            ? response.data
            : {'result': response.data},
        message: 'OTP sent successfully',
      );
    } on DioException catch (e) {
      String errorMessage = 'An error occurred while sending OTP';

      if (e.response?.data != null) {
        final errorData = e.response!.data;

        if (errorData is Map) {
          if (errorData['errors'] is List &&
              (errorData['errors'] as List).isNotEmpty) {
            errorMessage =
                errorData['errors'][0]['message']?.toString() ?? errorMessage;
          } else if (errorData['error'] != null) {
            errorMessage = errorData['error'].toString();
          } else if (errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          }
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      return ApiResponse.failure(message: errorMessage);
    } catch (e) {
      debugPrint('[GrievanceService] Unexpected error sending OTP: $e');
      return ApiResponse.failure(
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyOtp(
    VerifyOtpPayload payload,
  ) async {
    try {
      final response = await DioClient.dio.post(
        '/users/api/v1/citizens/verify-profile',
        data: payload.toJson(),
        options: Options(
          headers: ApiHeaders.build(
            clientId: 'darpg',
            sourceId: 'citizen.web',
            enableProtectedAuth: true,
            accessToken: await accessToken,
          ),
        ),
      );

      return ApiResponse.success(
        data: response.data['data'] ?? response.data,
        message: 'OTP verified successfully',
      );
    } on DioException catch (e) {
      final errorData = e.response?.data[0]['errors'];

      return ApiResponse.failure(
        message:
            errorData?['message'] ??
            errorData?.toString() ??
            e.message ??
            'Network error',
      );
    } catch (e) {
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

  Future<ApiResponse<Map<String, dynamic>>> uploadFiles(
    List<String> filePaths,
  ) async {
    try {
      if (filePaths.isEmpty) {
        return ApiResponse.failure(message: 'No files selected for upload');
      }

      final List<MultipartFile> multipartFiles = [];
      for (final path in filePaths) {
        multipartFiles.add(await MultipartFile.fromFile(path));
      }

      final formData = FormData.fromMap({"files": multipartFiles});

      final response = await DioClient.dio.post(
        "/grievances/api/v1/files",
        data: formData,
        options: Options(
          headers: ApiHeaders.build(
            sourceId: "citizen.web",
            clientId: "darpg",
            enableProtectedAuth: true,
            accessToken: await accessToken,
          ),
        ),
      );

      return ApiResponse.success(
        data: response.data,
        message: 'Files uploaded successfully',
      );
    } on DioException catch (e) {
      final errorData = e.response?.data;
      String errorMessage = 'Failed to upload files';
      if (errorData is Map) {
        errorMessage =
            errorData['message']?.toString() ??
            errorData['error']?.toString() ??
            errorMessage;
      }

      return ApiResponse.failure(message: errorMessage);
    } catch (e) {
      debugPrint('[GrievanceService] Unexpected error: $e');
      return ApiResponse.failure(
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> saveDraft(
    DraftModal payload,
    bool isAuthRequired,
  ) async {
    try {
      final accessToken = await SecureStorage.accessToken ?? "";
      final guestId = await SecureStorage.guestId ?? "";

      if (isAuthRequired && accessToken.isEmpty) {
        return ApiResponse.failure(
          message: 'Authentication required. Please login first.',
        );
      }

      if (!isAuthRequired && (accessToken.isEmpty || guestId.isEmpty)) {
        return ApiResponse.failure(
          message: 'Authentication required. Please login first.',
        );
      }

      final response = await DioClient.dio.post(
        "/grievances/api/v1/drafts",
        data: payload.toJson(),
        options: Options(
          headers: ApiHeaders.build(
            sourceId: "citizen.web",
            clientId: isAuthRequired ? "darpg" : "darpg-guest",
            enableProtectedAuth: isAuthRequired,
            enableAuth: !isAuthRequired,
            accessToken: accessToken,
            guestId: guestId,
          ),
        ),
      );

      return ApiResponse.success(
        data: response.data['data'] as Map<String, dynamic>? ?? {},
        message: 'Draft saved successfully',
      );
    } on DioException catch (e) {
      String errorMessage = 'An error occurred during logout';
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
      debugPrint('[GrievanceService] Unexpected error: $e');
      return ApiResponse.failure(
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> summaryGeneration(
    String text,
    String grievanceId,
    String? summaryOn,
  ) async {
    try {
      final accessToken = await SecureStorage.accessToken ?? "";

      if (accessToken.isEmpty) {
        return ApiResponse.failure(
          message: 'Authentication required. Please login first.',
        );
      }

      final aiApiBaseUrl = dotenv.env['PUBLIC_AI_API_URL'] ?? '';

      if (aiApiBaseUrl.isEmpty) {
        return ApiResponse.failure(
          message: 'AI API URL not configured. Please set PUBLIC_AI_API_URL.',
        );
      }

      final payload = <String, dynamic>{
        'grievance_text': text,
        'grievance_id': grievanceId,
      };

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': accessToken.startsWith('Bearer ')
            ? accessToken
            : 'Bearer $accessToken',
      };

      if (summaryOn != null && summaryOn.isNotEmpty) {
        headers['summary_on'] = summaryOn;
      }

      final response = await DioClient.aiDio.post(
        "/ai/grievance/api/v1/ai/grievance_details",
        data: payload,
        options: Options(headers: headers, validateStatus: (status) => true),
      );

      if (response.statusCode != null && response.statusCode! >= 400) {
        if (response.statusCode == 404) {
          debugPrint(
            '[GrievanceService] 404 Error - URL: ${DioClient.aiDio.options.baseUrl}/ai/grievance/api/v1/ai/grievance_details',
          );
        }
        return ApiResponse.failure(
          message: _extractErrorMessage(
            response.data,
            'Failed to generate summary',
          ),
        );
      }

      Map<String, dynamic> summaryData = response.data is Map<String, dynamic>
          ? Map<String, dynamic>.from(response.data)
          : {'raw': response.data};

      final responseStatus = summaryData['status']?.toString();
      final responseStatusCode = summaryData['status_code'] as int?;

      if (responseStatus == 'error' ||
          (responseStatusCode != null && responseStatusCode >= 400)) {
        return ApiResponse.failure(
          message: _extractErrorMessage(
            summaryData,
            'Failed to generate summary',
          ),
        );
      }

      try {
        if (summaryData.containsKey('payload') &&
            summaryData['payload'] is String) {
          try {
            final parsed = Map<String, dynamic>.from(
              const JsonDecoder().convert(summaryData['payload'] as String)
                  as Map,
            );
            summaryData['payload'] = parsed;
            summaryData = {...parsed, ...summaryData, 'payload': parsed};
          } catch (_) {}
        }

        if (summaryData.containsKey('summary') &&
            summaryData['summary'] is String) {
          try {
            final parsed = Map<String, dynamic>.from(
              const JsonDecoder().convert(summaryData['summary'] as String)
                  as Map,
            );
            summaryData['summary'] = parsed;
            summaryData = {...parsed, ...summaryData, 'summary': parsed};
          } catch (_) {}
        }
      } catch (_) {}

      return ApiResponse.success(
        data: summaryData,
        message: 'Summary generated successfully',
      );
    } on DioException catch (e) {
      final errorData = e.response?.data;
      String errorMessage = _extractErrorMessage(
        errorData,
        'An error occurred while generating summary',
      );

      if (errorData is Map && errorData['errors'] is List) {
        final errors = errorData['errors'] as List;
        if (errors.isNotEmpty) {
          errorMessage = errors[0]['message']?.toString() ?? errorMessage;
        }
      }

      debugPrint('[GrievanceService] Summary error: $errorMessage');
      return ApiResponse.failure(message: errorMessage);
    } catch (e) {
      debugPrint('[GrievanceService] Unexpected error: $e');
      return ApiResponse.failure(
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> spamDetection(
    String grievanceText,
  ) async {
    try {
      final accessToken = await SecureStorage.accessToken ?? "";

      if (accessToken.isEmpty) {
        return ApiResponse.failure(
          message: 'Authentication required. Please login first.',
        );
      }

      if (DioClient.aiDio.options.baseUrl.isEmpty) {
        return ApiResponse.failure(
          message: 'AI API URL not configured. Please set PUBLIC_AI_API_URL.',
        );
      }

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': accessToken.startsWith('Bearer ')
            ? accessToken
            : 'Bearer $accessToken',
      };

      final response = await DioClient.aiDio.post(
        "/ai/grievance/api/v1/ai/spam_detection",
        data: {'grievance_text': grievanceText},
        options: Options(headers: headers, validateStatus: (status) => true),
      );

      if (response.statusCode != null && response.statusCode! >= 400) {
        if (response.statusCode == 404) {
          debugPrint(
            '[GrievanceService] 404 Error - URL: ${DioClient.aiDio.options.baseUrl}/ai/grievance/api/v1/ai/spam_detection',
          );
        }
        return ApiResponse.failure(
          message: _extractErrorMessage(response.data, 'Failed to check spam'),
        );
      }

      Map<String, dynamic> spamData = response.data is Map<String, dynamic>
          ? Map<String, dynamic>.from(response.data)
          : {'raw': response.data};

      final responseStatus = spamData['status']?.toString();
      final responseStatusCode = spamData['status_code'] as int?;

      if (responseStatus == 'error' ||
          (responseStatusCode != null && responseStatusCode >= 400)) {
        return ApiResponse.failure(
          message: _extractErrorMessage(spamData, 'Failed to check spam'),
        );
      }

      return ApiResponse.success(
        data: spamData,
        message: 'Spam check completed successfully',
      );
    } on DioException catch (e) {
      final errorData = e.response?.data;
      String errorMessage = _extractErrorMessage(
        errorData,
        'An error occurred while checking spam',
      );

      if (errorData is Map && errorData['errors'] is List) {
        final errors = errorData['errors'] as List;
        if (errors.isNotEmpty) {
          errorMessage = errors[0]['message']?.toString() ?? errorMessage;
        }
      }

      return ApiResponse.failure(message: errorMessage);
    } catch (e) {
      debugPrint('[GrievanceService] Unexpected error: $e');
      return ApiResponse.failure(
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> duplicateDetection(
    String grievanceText, {
    String? grievanceId,
    String? locationId,
    String? userId,
  }) async {
    try {
      final accessToken = await SecureStorage.accessToken ?? "";

      if (accessToken.isEmpty) {
        return ApiResponse.failure(
          message: 'Authentication required. Please login first.',
        );
      }

      if (DioClient.aiDio.options.baseUrl.isEmpty) {
        return ApiResponse.failure(
          message: 'AI API URL not configured. Please set PUBLIC_AI_API_URL.',
        );
      }

      final payload = <String, dynamic>{
        'grievance_text': grievanceText,
        if (grievanceId != null && grievanceId.isNotEmpty)
          'grievance_id': grievanceId,
        if (locationId != null && locationId.isNotEmpty)
          'location_id': locationId,
        if (userId != null && userId.isNotEmpty) 'user_id': userId,
      };

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': accessToken.startsWith('Bearer ')
            ? accessToken
            : 'Bearer $accessToken',
      };

      final response = await DioClient.aiDio.post(
        "/ai/grievance/api/v1/ai/duplicate_detection",
        data: payload,
        options: Options(headers: headers, validateStatus: (status) => true),
      );

      if (response.statusCode != null && response.statusCode! >= 400) {
        return ApiResponse.failure(
          message: _extractErrorMessage(
            response.data,
            'Failed to check duplicate',
          ),
        );
      }

      Map<String, dynamic> duplicateData = response.data is Map<String, dynamic>
          ? Map<String, dynamic>.from(response.data)
          : {'raw': response.data};

      final responseStatus = duplicateData['status']?.toString();
      final responseStatusCode = duplicateData['status_code'] as int?;

      if (responseStatus == 'error' ||
          (responseStatusCode != null && responseStatusCode >= 400)) {
        return ApiResponse.failure(
          message: _extractErrorMessage(
            duplicateData,
            'Failed to check duplicate',
          ),
        );
      }

      return ApiResponse.success(
        data: duplicateData,
        message: 'Duplicate check completed successfully',
      );
    } on DioException catch (e) {
      final errorData = e.response?.data;
      String errorMessage = _extractErrorMessage(
        errorData,
        'An error occurred while checking duplicates',
      );

      if (errorData is Map && errorData['errors'] is List) {
        final errors = errorData['errors'] as List;
        if (errors.isNotEmpty) {
          errorMessage = errors[0]['message']?.toString() ?? errorMessage;
        }
      }

      return ApiResponse.failure(message: errorMessage);
    } catch (e) {
      debugPrint('[GrievanceService] Unexpected error: $e');
      return ApiResponse.failure(
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }
}
