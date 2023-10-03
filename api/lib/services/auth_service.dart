import 'package:chat/exceptions/chat_exception.dart';
import 'package:chat/generated/dsql.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dsql/dsql.dart';

typedef AuthCredentials = ({String accessToken, String refreshToken});

class AuthService {
  late final SecretKey _secret;
  final DSQL dsql;

  AuthService(this.dsql) {
    _secret = SecretKey(String.fromEnvironment('JWT_SECRET'));
  }

  Future<AuthCredentials> sign(UserEntity user) async {
    try {
      final now = DateTime.now().toUtc();

      final accessToken = JWT({
        'iat': now.millisecondsSinceEpoch ~/ 1000,
        'exp': now.add(Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
        'sub': user.id,
        'typ': 'token',
        'iss': 'tihrasguinho.dev',
      }).sign(_secret);

      final refreshToken = JWT({
        'iat': now.millisecondsSinceEpoch ~/ 1000,
        'exp': now.add(Duration(days: 7)).millisecondsSinceEpoch ~/ 1000,
        'sub': user.id,
        'typ': 'refresh',
        'iss': 'tihrasguinho.dev',
      }).sign(_secret);

      final check = await dsql.auth.findFirst(where: Where('user_id', EQ(user.id)));

      if (check != null) {
        await dsql.auth.update(
          where: Where('user_id', EQ(user.id)),
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      } else {
        await dsql.auth.create(
          userId: user.id,
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      }

      return (accessToken: accessToken, refreshToken: refreshToken);
    } on ChatException {
      rethrow;
    } on Exception catch (e) {
      throw BadRequestException(e.toString());
    }
  }

  Future<UserEntity> verify(String token) async {
    try {
      final jwt = JWT.verify(token, _secret);

      final sub = jwt.payload['sub'] as String;

      final user = await dsql.user.findFirst(where: Where('id', EQ(sub)));

      if (user == null) {
        throw UnauthorizedException('Invalid token!');
      }

      return user;
    } on ChatException {
      rethrow;
    } on Exception catch (e) {
      throw BadRequestException(e.toString());
    }
  }

  Future<AuthCredentials> refreshToken(String token) async {
    try {
      final credentials = await dsql.auth.findFirst(where: Where('refresh_token', EQ(token)));

      if (credentials == null) {
        throw UnauthorizedException('Invalid token!');
      }

      JWT.verify(token, _secret);

      final now = DateTime.now().toUtc();

      final accessToken = JWT({
        'iat': now.millisecondsSinceEpoch ~/ 1000,
        'exp': now.add(Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
        'sub': credentials.userId,
        'typ': 'token',
        'iss': 'tihrasguinho.dev',
      }).sign(_secret);

      final refreshToken = JWT({
        'iat': now.millisecondsSinceEpoch ~/ 1000,
        'exp': now.add(Duration(days: 7)).millisecondsSinceEpoch ~/ 1000,
        'sub': credentials.userId,
        'typ': 'refresh',
        'iss': 'tihrasguinho.dev',
      }).sign(_secret);

      await dsql.auth.update(
        where: Where('user_id', EQ(credentials.userId)),
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      return (accessToken: accessToken, refreshToken: refreshToken);
    } on ChatException {
      rethrow;
    } on Exception catch (e) {
      throw BadRequestException(e.toString());
    }
  }

  Future<void> signOut(UserEntity user) async {
    try {
      final credentials = await dsql.auth.delete(where: Where('user_id', EQ(user.id)));

      if (credentials == null) {
        throw UnauthorizedException('Invalid token!');
      }

      return;
    } on ChatException {
      rethrow;
    } on Exception catch (e) {
      throw BadRequestException(e.toString());
    }
  }
}
