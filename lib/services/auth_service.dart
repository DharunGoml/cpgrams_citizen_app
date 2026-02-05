import 'package:cpgrams_citizen_app/models/api_response.dart';
import 'package:cpgrams_citizen_app/models/auth/otp_modal.dart';
import 'package:cpgrams_citizen_app/network/api_headers.dart';
import 'package:cpgrams_citizen_app/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AuthAPISerivce {
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String grantType,
    required String userName,
    required String password,
  }) async {
    try {
      final formData = FormData.fromMap({
        'grant_type': grantType,
        'username': userName,
        'password': password,
      });

      final response = await DioClient.dio.post(
        "/auth/token/v1/login",
        data: formData,
        options: Options(
          headers: ApiHeaders.build(sourceId: 'citizen.web', clientId: 'darpg'),
        ),
      );

      return ApiResponse.success(
        data: response.data,
        message: 'Login successful',
      );
    } on DioException catch (e) {
      String errorMessage = 'An error occurred during login';
      if (e.response?.data?['errors'] != null) {
        final errors = e.response!.data['errors'];
        if (errors is List && errors.isNotEmpty) {
          errorMessage = errors[0]['message'] ?? errorMessage;
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      return ApiResponse.failure(message: errorMessage);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> sendOtp(
    SendOtpPayload payload,
  ) async {
    try {
      final response = await DioClient.dio.post(
        '/users/api/v1/otp/send',
        data: payload.toJson(),
        options: Options(
          headers: ApiHeaders.build(sourceId: 'citizen.web', clientId: 'darpg'),
        ),
      );

      return ApiResponse.success(
        data: response.data,
        message: 'OTP sent successfully',
      );
    } on DioException catch (e) {
      // Extract error message from response
      String errorMessage = 'An error occurred';

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
      return ApiResponse.failure(message: 'An unexpected error occurred');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> resendOtp(
    SendOtpPayload payload,
  ) async {
    try {
      final response = await DioClient.dio.post(
        "/users/api/v1/otp/send",
        data: payload.toJson(),
        options: Options(
          headers: ApiHeaders.build(sourceId: 'citizen.web', clientId: 'darpg'),
        ),
      );
      return ApiResponse.success(
        data: response.data,
        message: 'OTP resent successfully',
      );
    } on DioException catch (e) {
      // Extract error message from response
      String errorMessage = 'An error occurred';

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
      return ApiResponse.failure(message: 'An unexpected error occurred');
    }
  }

  Future<String> fetchSSOLoginUrl(String ssoType) async {
    try {
      final response = await DioClient.dio.get(
        "/auth/sso/v1/get-login",
        options: Options(
          responseType: ResponseType.plain,
          headers: {
            'sso-type': ssoType,
            'redirect-url': 'cpgrams://auth/callback',
          },
        ),
      );

      return response.data;
    } on DioException catch (e) {
      // Extract error message from response
      String errorMessage = 'An error occurred';

      if (e.response?.data?['errors'] != null) {
        final errors = e.response!.data['errors'];
        if (errors is List && errors.isNotEmpty) {
          errorMessage = errors[0]['message'] ?? errorMessage;
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }

      return errorMessage;
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  Future<void> exchangeSSOToken({
    required String ssoType,
    required String code,
  }) async {
    try {
      final response = await DioClient.dio.post(
        "/auth/sso/v1/generate-token",
        options: Options(
          headers: {
            'sso-type': ssoType,
            'sso-code': code,
            'redirect-url': 'cpgrams://auth/callback',
            'x-client-id': 'darpg',
          },
        ),
      );

      final data = response.data;

      print('SSO Token Exchange Response: $data');
    } catch (e) {
      debugPrint('Error exchanging SSO token: $e');
    }
  }
}
