import 'package:chat/chat.dart';
import 'package:chat/controllers/auth/auth_controller.dart';
import 'package:chat/controllers/profile/profile_controller.dart';
import 'package:chat/controllers/users/users_controller.dart';
import 'package:chat/middlewares/auth_middleware.dart';
import 'package:shelf_express/shelf_express.dart';

void main() async {
  await init();

  final express = Express()
    ..middleware(logger)
    ..middleware(authMiddleware(['/auth/signin', '/auth/signup', '/auth/refresh-token']))
    ..use(AuthController())
    ..use(UsersController())
    ..use(ProfileController());

  await express.start(onListen: () => print('Listening on http://localhost:8080'));
}
