import 'dart:io';

import 'package:chat/chat.dart';
import 'package:chat/exceptions/chat_exception.dart';
import 'package:chat/generated/dsql.dart';
import 'package:chat/services/auth_service.dart';
import 'package:dsql/dsql.dart';
import 'package:shelf_express/shelf_express.dart';

import 'params/signin_params.dart';
import 'params/signup_params.dart';

class AuthController extends Controller {
  AuthController() : super('/auth') {
    post('/signin', signIn);
    post('/signup', signUp);
    post('/refresh-token', refreshToken);
    post('/signout', signOut);
  }

  Future<Response> signIn(Request request) async {
    try {
      final params = await SigninParams.fromRequest(request);

      final dsql = injector.get<DSQL>();

      final auth = injector.get<AuthService>();

      final user = await dsql.user.findFirst(
        where: Where('email', EQ(params.email)),
        orderBy: ASC('email'),
      );

      if (user == null) {
        throw NotFoundException('User not found!');
      }

      if (!Password.verify(params.password, user.password)) {
        throw UnauthorizedException('Invalid password!');
      }

      final credentials = await auth.sign(user);

      return Response.json(
        statusCode: HttpStatus.ok,
        body: {
          'access_token': credentials.accessToken,
          'refresh_token': credentials.refreshToken,
          'expires_in': 3600,
        },
      );
    } on ChatException catch (e) {
      return e.toResponse;
    } on Exception catch (e) {
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {
          'error': e.toString(),
        },
      );
    }
  }

  Future<Response> signUp(Request request) async {
    try {
      final params = await SignupParams.fromRequest(request);

      final dsql = injector.get<DSQL>();

      final auth = injector.get<AuthService>();

      final check = await dsql.user.findFirst(
        where: Where('email', EQ(params.email)),
        orderBy: ASC('email'),
      );

      if (check != null) {
        throw ConflictException('User already exists!');
      }

      final user = await dsql.user.create(
        name: params.name,
        email: params.email,
        password: Password.hash(params.password),
      );

      final credentials = await auth.sign(user);

      return Response.json(
        statusCode: HttpStatus.created,
        body: {
          'access_token': credentials.accessToken,
          'refresh_token': credentials.refreshToken,
          'expires_in': 3600,
        },
      );
    } on ChatException catch (e) {
      return e.toResponse;
    } on Exception catch (e) {
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {
          'error': e.toString(),
        },
      );
    }
  }

  Future<Response> refreshToken(Request request) async {
    try {
      final authorization = request.authorization;

      if (authorization.isEmpty) {
        throw UnauthorizedException('Invalid token!');
      }

      final auth = injector.get<AuthService>();

      final credentials = await auth.refreshToken(authorization);

      return Response.json(
        body: {
          'access_token': credentials.accessToken,
          'refresh_token': credentials.refreshToken,
          'expires_in': 3600,
        },
      );
    } on ChatException catch (e) {
      return e.toResponse;
    } on Exception catch (e) {
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {
          'error': e.toString(),
        },
      );
    }
  }

  Future<Response> signOut(Request request) async {
    try {
      final user = request.fromContext<UserEntity>('user');

      if (user == null) {
        throw UnauthorizedException('Invalid token!');
      }

      final auth = injector.get<AuthService>();

      await auth.signOut(user);

      return Response.json(statusCode: HttpStatus.noContent);
    } on ChatException catch (e) {
      return e.toResponse;
    } on Exception catch (e) {
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {
          'error': e.toString(),
        },
      );
    }
  }
}
