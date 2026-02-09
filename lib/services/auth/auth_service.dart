import 'dart:convert';

import 'package:cpgrams_citizen_app/models/api_response.dart';
import 'package:cpgrams_citizen_app/models/auth/otp_modal.dart';
import 'package:cpgrams_citizen_app/network/api_headers.dart';
import 'package:cpgrams_citizen_app/network/dio_client.dart';
import 'package:cpgrams_citizen_app/utils/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AuthAPISerivce {
  // Public getters for accessing stored data
  static Future<String?> get accessToken => SecureStorage.accessToken;
  static Future<String?> get refreshToken => SecureStorage.refreshToken;
  static Future<String?> get guestId => SecureStorage.guestId;
  static Future<String?> get userId => SecureStorage.userId;
  static Future<String?> get userDetails => SecureStorage.userDetails;
  static Future<bool> get isGuest => SecureStorage.isGuest;

  static Future<void> clearAuth() async {
    await SecureStorage.clear();
  }

  Future<ApiResponse<Map<String, dynamic>>> login({
    required String grantType,
    required String userName,
    required String password,
  }) async {
    clearAuth();
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

      // Store tokens and user data
      final data = response.data['data'];
      if (data != null) {
        await SecureStorage.set('access_token', data['access_token'] ?? '');
        await SecureStorage.set('refresh_token', data['refresh_token'] ?? '');
        await SecureStorage.set('token_type', data['token_type'] ?? '');
        await SecureStorage.set('is_guest', 'false');

        if (data['user_details'] != null) {
          final userDetails = data['user_details'];
          await SecureStorage.set('user_id', userDetails['user_id'] ?? '');
          await SecureStorage.set('user_details', jsonEncode(userDetails));
        }
      }

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
    } catch (e) {
      return ApiResponse.failure(message: 'An unexpected error occurred');
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
      // final response =
      await DioClient.dio.post(
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

      // final data = response.data;

      // print('SSO Token Exchange Response: $data');
    } catch (e) {
      debugPrint('Error exchanging SSO token: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> register({
    required String firstName,
    required String lastName,
    required String password,
    required String confirmPassword,
    required List<Map<String, String>> identifiers,
  }) async {
    clearAuth();
    try {
      final payload = {
        "data": {
          "firstName": firstName,
          "lastName": lastName,
          "password": password,
          "language": "en_US",
          "confirmPassword": confirmPassword,
          "identifiers": identifiers,
        },
      };

      final response = await DioClient.dio.post(
        "/users/api/v1/citizens/register",
        data: jsonEncode(payload),
        options: Options(
          headers: ApiHeaders.build(
            sourceId: 'citizen.web',
            clientId: 'auth-service',
          ),
        ),
      );

      return ApiResponse.success(
        data: response.data,
        message: 'Registration successful',
      );
    } on DioException catch (e) {
      String errorMessage = 'An error occurred during registration';
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

  Future<ApiResponse<Map<String, dynamic>>> verifyOtp({
    required String uuid,
    required String emailOtp,
    required String smsOtp,
  }) async {
    try {
      final payload = {
        "data": {"uuid": uuid, "emailOtp": emailOtp, "smsOtp": smsOtp},
      };

      final response = await DioClient.dio.post(
        "/users/api/v1/citizens/verify",
        data: jsonEncode(payload),
        options: Options(
          headers: ApiHeaders.build(sourceId: "citizen.web", clientId: "darpg"),
        ),
      );

      return ApiResponse.success(
        data: response.data,
        message: 'OTP verified successfully',
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
      debugPrint('Error verifying OTP: $e');
      return ApiResponse.failure(message: 'An unexpected error occurred');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> passwordReset({
    required String identifier,
    required String otp,
    required String newPassword,
    required String conformPassword,
  }) async {
    try {
      final payload = {
        "identifier": identifier,
        "otp": otp,
        "newPassword": newPassword,
        "conformPassword": conformPassword,
      };
      final response = await DioClient.dio.post(
        "/users/api/v1/confirm-password-reset",
        data: jsonEncode(payload),
        options: Options(
          headers: ApiHeaders.build(sourceId: "citizen.web", clientId: "darpg"),
        ),
      );

      return ApiResponse.success(
        data: response.data,
        message: 'Password reset successful',
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
      debugPrint('Error resetting password: $e');
      return ApiResponse.failure(message: "An unexpected error occurred");
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> guestLogin() async {
    try {
      // await clearAuth();
      final reponse = await DioClient.dio.post(
        "/auth/guest/v1/login",
        options: Options(
          headers: ApiHeaders.build(
            sourceId: "citizen.web",
            clientId: "darpg-guest",
          ),
        ),
      );

      if (reponse.statusCode != 200) {
        return ApiResponse.failure(message: "Guest login failed");
      }

      // Store guest tokens and data
      final data = reponse.data['data'];
      if (data != null) {
        await SecureStorage.set('access_token', data['access_token'] ?? '');
        await SecureStorage.set('guest_id', data['guest_id'] ?? '');
        await SecureStorage.set('token_type', data['token_type'] ?? '');
        await SecureStorage.set('is_guest', 'true');
      }

      return ApiResponse.success(
        data: reponse.data,
        message: 'Guest login successful',
      );
    } catch (e) {
      return ApiResponse.failure(message: "An unexpected error occurred");
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> logout() async {
    try {
      // Get the current access token
      final token = await accessToken;

      if (token == null || token.isEmpty) {
        await clearAuth();
        return ApiResponse.failure(message: "No active session found");
      }

      final response = await DioClient.dio.post(
        "/auth/token/v1/logout",
        options: Options(
          headers: ApiHeaders.build(
            sourceId: "citizen.web",
            clientId: "darpg",
            enableAuth: true,
            accessToken: token,
          ),
        ),
      );

      // Clear all stored auth data after successful logout
      await clearAuth();

      return ApiResponse.success(
        data: response.data,
        message: 'Logout successful',
      );
    } on DioException catch (e) {
      // Clear auth data even if API call fails
      await clearAuth();

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
      // Clear auth data even if unexpected error occurs
      await clearAuth();
      debugPrint('Error during logout: $e');
      return ApiResponse.failure(message: "An unexpected error occurred");
    }
  }
}
