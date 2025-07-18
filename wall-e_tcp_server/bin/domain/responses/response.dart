class Response {
  final String status;
  final String message;
  final int statusCode;

  Response({
    required this.status,
    required this.statusCode,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'statusCode': '$statusCode',
    };
  }
}
