import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DioClient {
  static final Dio dio = _createDio();
  static final Dio aiDio = _createAiDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['PUBLIC_API_URL'] ?? '',
        connectTimeout: const Duration(milliseconds: 10000),
        // receiveTimeout: const Duration(milliseconds: 10000),
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    );

    return dio;
  }

  static Dio _createAiDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['PUBLIC_AI_API_URL'] ?? '',
        connectTimeout: const Duration(milliseconds: 20000),
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    );

    return dio;
  }
}
