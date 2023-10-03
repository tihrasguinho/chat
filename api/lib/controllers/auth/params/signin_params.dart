import 'package:chat/exceptions/chat_exception.dart';
import 'package:shelf_express/shelf_express.dart';

class SigninParams {
  final String email;
  final String password;

  SigninParams({required this.email, required this.password}) {
    validate();
  }

  void validate() {
    if (email.isEmpty) {
      throw BadRequestException('Email is required!');
    }

    if (password.isEmpty) {
      throw BadRequestException('Password is required!');
    }
  }

  static Future<SigninParams> fromRequest(Request request) async {
    final body = await request.body();

    return SigninParams(
      email: body['email'] ?? '',
      password: body['password'] ?? '',
    );
  }
}
