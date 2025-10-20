class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Object? json)? fromJsonT) {
    return ApiResponse(
      success: json['success'],
      message: json['message'],
      data: fromJsonT != null && json['data'] != null ? fromJsonT(json['data']) : json['data'],
    );
  }
}