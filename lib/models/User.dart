class User {
  String userName;
  String password;
  String email;
  String? phoneNumber;
  String? token;

  User({
    required this.userName,
    required this.password,
    required this.email,
    this.phoneNumber,
    this.token
  });

  Map<String, dynamic> toMap() {
    return {
      'username': userName,
      'password': password,
      'email': email,
      'phoneNumber': phoneNumber,
      'token':token
    };
  }
}