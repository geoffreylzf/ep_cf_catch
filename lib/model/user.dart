import 'dart:convert';

class User {
  final String username, password;

  User(this.username, this.password);

  String getCredential() {
    return 'Basic ' + base64Encode(utf8.encode('$username:$password'));
  }
}
