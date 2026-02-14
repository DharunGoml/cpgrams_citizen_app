import 'package:cpgrams_citizen_app/models/api_response.dart';
import 'package:cpgrams_citizen_app/models/form/form_modal.dart';
import 'package:cpgrams_citizen_app/network/api_headers.dart';
import 'package:cpgrams_citizen_app/network/dio_client.dart';
import 'package:dio/dio.dart';

class FormService {
  Future<ApiResponse<Map<String, dynamic>>> getFormData(
    FormModal payload,
  ) async {
    try {
      final response = await DioClient.dio.post(
        "/forms/api/v1/get",
        data: payload.toJson(),
        options: Options(
          headers: ApiHeaders.build(
            sourceId: "citizen.web",
            clientId: "darpg",
            enableAuth: false,
          ),
        ),
      );
      return ApiResponse.success(
        data: response.data?['data'],
        message: "Form data fetched successfully",
      );
    } catch (e) {
      return ApiResponse.failure(
        message: "An unexpected error occurred: ${e.toString()}",
      );
    }
  }
}
