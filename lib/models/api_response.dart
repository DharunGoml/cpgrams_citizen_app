class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;

  ApiResponse({required this.success, this.message, this.data});

  factory ApiResponse.success({T? data, String? message}) {
    return ApiResponse(success: true, data: data, message: message);
  }

  factory ApiResponse.failure({required String message}) {
    return ApiResponse(success: false, message: message, data: null);
  }
}
