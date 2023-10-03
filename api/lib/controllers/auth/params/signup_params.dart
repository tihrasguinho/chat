import 'package:chat/exceptions/chat_exception.dart';
import 'package:shelf_express/shelf_express.dart';

class SignupParams {
  final String name;
  final String email;
  final String password;

  SignupParams({required this.name, required this.email, required this.password}) {
    validate();
  }

  void validate() {
    if (name.isEmpty) {
      throw BadRequestException('Name is required!');
    }

    if (email.isEmpty) {
      throw BadRequestException('Email is required!');
    }

    if (password.isEmpty) {
      throw BadRequestException('Password is required!');
    }
  }

  static Future<SignupParams> fromRequest(Request request) async {
    final body = await request.body();

    return SignupParams(
      name: body['name'] ?? '',
      email: body['email'] ?? '',
      password: body['password'] ?? '',
    );
  }
}
