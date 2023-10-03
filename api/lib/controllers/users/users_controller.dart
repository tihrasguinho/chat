import 'dart:io';

import 'package:chat/chat.dart';
import 'package:chat/dtos/user_dto.dart';
import 'package:chat/exceptions/chat_exception.dart';
import 'package:chat/generated/dsql.dart';
import 'package:dsql/dsql.dart';
import 'package:shelf_express/shelf_express.dart';

class UsersController extends Controller {
  UsersController() : super('/users') {
    get('/', index);
    get('/<id>', show);
  }

  Future<Response> index(Request request) async {
    try {
      final user = request.fromContext<UserEntity>('user');

      if (user == null) {
        throw UnauthorizedException('Invalid token!');
      }

      final dsql = injector.get<DSQL>();

      final where = Where('id', NOTEQ(user.id));

      Where? other;

      for (var i = 0; i < request.queryParams.length; i++) {
        final key = request.queryParams.keys.elementAt(i);
        final value = request.queryParams.values.elementAt(i);

        if (key == 'name' && other == null) {
          other = Where('name', StartsWith(value));
        } else if (key == 'name' && other != null) {
          other.or(Where('name', StartsWith(value)));
        } else if (key == 'email' && other == null) {
          other = Where('email', StartsWith(value));
        } else if (key == 'email' && other != null) {
          other.or(Where('email', StartsWith(value)));
        } else if (key == 'created_at' && other == null) {
          other = Where('created_at', LTE(DateTime.parse(value)));
        } else if (key == 'created_at' && other != null) {
          other.or(Where('created_at', LTE(DateTime.parse(value))));
        }
      }

      final offset = int.parse(request.queryParams['offset'] ?? '0');

      final limit = int.parse(request.queryParams['limit'] ?? '10');

      final users = await dsql.user.findMany(
        where: other != null ? where.and(Where.emphasis(other)) : where,
        limit: limit > 10 ? 10 : limit,
        offset: offset,
        orderBy: DESC('created_at'),
      );

      return Response.json(
        body: {
          'users': users.map((item) => item.toResponse()).toList(),
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

  Future<Response> show(Request request, String id) async {
    try {
      final user = request.fromContext<UserEntity>('user');

      if (user == null) {
        throw UnauthorizedException('Invalid token!');
      }

      final dsql = injector.get<DSQL>();

      final userEntity = await dsql.user.findFirst(where: Where('id', EQ(id)));

      if (userEntity == null) {
        throw NotFoundException('User not found!');
      }

      return Response.json(
        body: {
          'user': userEntity.toResponse(),
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
}
