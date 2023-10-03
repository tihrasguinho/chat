import 'dart:io';

import 'package:chat/chat.dart';
import 'package:chat/exceptions/chat_exception.dart';
import 'package:chat/services/auth_service.dart';
import 'package:shelf_express/shelf_express.dart';

Middleware authMiddleware([List<String> nonAuthPaths = const []]) {
  return (Handler handler) {
    return (Request request) async {
      try {
        if (nonAuthPaths.contains(request.path)) {
          return handler(request);
        }

        final authorization = request.authorization;

        if (authorization.isEmpty) {
          throw UnauthorizedException('Invalid token!');
        }

        final auth = injector.get<AuthService>();

        final user = await auth.verify(authorization);

        final newRequest = request.change(context: {'user': user});

        return handler(newRequest);
      } on ChatException catch (e) {
        return e.toResponse;
      } on Exception {
        return Response.json(
          statusCode: HttpStatus.unauthorized,
          body: {
            'error': 'Invalid token!',
          },
        );
      }
    };
  };
}
