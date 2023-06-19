class User {
  String username;
  String password;
  String email;
  String? phonenumber;
  String? token;

  User({
    required this.username,
    required this.password,
    required this.email,
    this.phonenumber,
    this.token
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'email': email,
      'phonenumber': phonenumber,
      'token':token
    };
  }
}