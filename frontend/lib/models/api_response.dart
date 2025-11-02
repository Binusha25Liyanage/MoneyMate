class ApiResponse<T> {
  final bool success;
  final String? message; // Changed to nullable
  final T? data;

  ApiResponse({
    required this.success,
    this.message, // Made nullable
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Object? json)? fromJsonT) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString(), // Handle null and convert to string
      data: fromJsonT != null && json['data'] != null ? fromJsonT(json['data']) : json['data'],
    );
  }

  // Helper method to get message with fallback
  String get messageWithFallback => message ?? (success ? 'Success' : 'An error occurred');
}