import 'dart:io';

import 'package:chat/chat.dart';
import 'package:chat/dtos/user_dto.dart';
import 'package:chat/exceptions/chat_exception.dart';
import 'package:chat/generated/dsql.dart';
import 'package:dsql/dsql.dart';
import 'package:shelf_express/shelf_express.dart';

class ProfileController extends Controller {
  ProfileController() : super('/profile') {
    get('/', profile);
    post('/send-friend-request', sendFriendRequest);
    get('/friend-requests', friendRequests);
    post('/respond-friend-request', respondFriendRequest);
    get('/friends', friends);
  }

  Future<Response> profile(Request request) async {
    try {
      final user = request.fromContext<UserEntity>('user');

      if (user == null) {
        throw UnauthorizedException('Invalid token!');
      }

      return Response.json(
        body: {
          'user': user.toResponse(),
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

  Future<Response> sendFriendRequest(Request request) async {
    try {
      final user = request.fromContext<UserEntity>('user');

      if (user == null) {
        throw UnauthorizedException('Invalid token!');
      }

      final body = await request.body();

      if (body['friend_id'] == null || body['friend_id'] is! String) {
        throw BadRequestException('You must provide a friend id!');
      }

      final dsql = injector.get<DSQL>();

      final checkOne = await dsql.friendRequest.findFirst(where: Where('user_id', EQ(user.id)).and(Where('friend_id', EQ(body['friend_id']))));

      if (checkOne != null) {
        throw ConflictException('Friend request already exists!');
      }

      final checkTwo = await dsql.friendRequest.findFirst(where: Where('user_id', EQ(body['friend_id'])).and(Where('friend_id', EQ(user.id))));

      if (checkTwo != null) {
        throw BadRequestException('You already have a friend request from this user!');
      }

      await dsql.friendRequest.create(userId: user.id, friendId: body['friend_id']);

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

  Future<Response> friendRequests(Request request) async {
    try {
      final user = request.fromContext<UserEntity>('user');

      if (user == null) {
        throw UnauthorizedException('Invalid token!');
      }

      final dsql = injector.get<DSQL>();

      final requests = await dsql.friendRequest.findMany(where: Where('friend_id', EQ(user.id)));

      final users = <UserEntity>[];

      for (final r in requests) {
        final other = await dsql.user.findFirst(where: Where('id', EQ(r.userId)));

        if (other != null) {
          users.add(other);
        }
      }

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

  Future<Response> respondFriendRequest(Request request) async {
    try {
      final user = request.fromContext<UserEntity>('user');

      if (user == null) {
        throw UnauthorizedException('Invalid token!');
      }

      final body = await request.body();

      if (body['friend_id'] == null || body['friend_id'] is! String) {
        throw BadRequestException('You must provide a friend id!');
      }

      if (body['response'] == null || body['response'] is! bool) {
        throw BadRequestException('You must provide a response value {True} or {False}!');
      }

      final dsql = injector.get<DSQL>();

      final checkRequest = await dsql.friendRequest.findFirst(where: Where('user_id', EQ(body['friend_id'])).and(Where('friend_id', EQ(user.id))));

      if (checkRequest == null) {
        throw NotFoundException('Friend request not found!');
      }

      if (body['response'] == true) {
        await Future.wait([
          dsql.friend.create(userId: checkRequest.userId, friendId: checkRequest.friendId),
          dsql.friend.create(userId: checkRequest.friendId, friendId: checkRequest.userId),
          dsql.friendRequest.delete(where: Where('id', EQ(checkRequest.id))),
        ]);
      } else {
        await dsql.friendRequest.delete(where: Where('id', EQ(checkRequest.id)));
      }

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

  Future<Response> friends(Request request) async {
    try {
      final user = request.fromContext<UserEntity>('user');

      if (user == null) {
        throw UnauthorizedException('Invalid token!');
      }

      final dsql = injector.get<DSQL>();

      final friends = await dsql.friend.findMany(where: Where('user_id', EQ(user.id)));

      final users = <UserEntity>[];

      for (final friend in friends) {
        final other = await dsql.user.findFirst(where: Where('id', EQ(friend.friendId)));

        if (other != null) {
          users.add(other);
        }
      }

      return Response.json(
        body: {
          'users': users.map((item) => item.toResponse()).toList(),
        },
      );
    } on ChatException catch (e) {
      return e.toResponse;
    } on Exception {
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {
          'error': 'Something went wrong!',
        },
      );
    }
  }
}
