class Auth {
  final bool success;
  final String message;

  Auth({this.success, this.message}) {
    if (!success) {
      throw Exception(message);
    }
  }

  factory Auth.fromJson(Map<String, dynamic> json) =>
      Auth(success: json['success'], message: json['message']);
}
