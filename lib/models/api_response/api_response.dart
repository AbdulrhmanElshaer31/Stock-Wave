class ApiResponse<T> {
  final bool isLoading;
  final T? data;
  final int? statusCode;
  final String? error;
  ApiResponse({this.isLoading = false, this.data, this.statusCode, this.error});
  factory ApiResponse.loading() => ApiResponse(isLoading: true);
  factory ApiResponse.success({T? data, int? statusCode}) =>
      ApiResponse(isLoading: false, data: data, statusCode: statusCode);
  factory ApiResponse.error({String? error, int? statusCode}) =>
      ApiResponse(isLoading: false, error: error, statusCode: statusCode);
}
