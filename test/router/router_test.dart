import 'dart:convert';

import 'package:server/constants/constants.dart';
import 'package:server/di/di.dart';
import 'package:server/dto/request.dart';
import 'package:server/handler/handler.dart';
import 'package:server/model/todo.dart';
import 'package:server/repository/repository.dart';
import 'package:server/router/router.dart';
import 'package:server/service/service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart' as shelf_router;
import 'package:test/test.dart';

void main() {
  group('Routes', () {
    late Routes routes;
    late MockDI mockDI;
    late MockHandler mockHandler;
    late shelf_router.Router router;

    setUp(() {
      router = shelf_router.Router();
      mockHandler = MockHandler();
      mockDI = MockDI(mockHandler);
      routes = Routes(router, mockDI);
    });

    test('should register POST /todo route', () async {
      mockHandler.createResponse = Response.ok(
        jsonEncode({'result': {'id': 1, 'title': 'Test', 'status': 0}}),
        headers: {'content-type': 'application/json'},
      );

      final request = Request(
        'POST',
        Uri.parse('http://localhost/todo'),
        body: jsonEncode({'title': 'Test', 'status': 0}),
      );

      final response = await routes.router.call(request);

      expect(response.statusCode, equals(200));
    });

    test('should register GET /todo route', () async {
      mockHandler.getAllResponse = Response.ok(
        jsonEncode({'result': []}),
        headers: {'content-type': 'application/json'},
      );

      final request = Request(
        'GET',
        Uri.parse('http://localhost/todo'),
      );

      final response = await routes.router.call(request);

      expect(response.statusCode, equals(200));
    });

    test('should register GET /todo/<id> route', () async {
      mockHandler.getByIdResponse = Response.ok(
        jsonEncode({'result': {'id': 1, 'title': 'Test', 'status': 0}}),
        headers: {'content-type': 'application/json'},
      );

      final request = Request(
        'GET',
        Uri.parse('http://localhost/todo/1'),
      );

      final response = await routes.router.call(request);

      expect(response.statusCode, equals(200));
    });

    test('should register PUT /todo/<id> route', () async {
      mockHandler.updateResponse = Response.ok(
        jsonEncode({'result': {'id': 1, 'title': 'Updated', 'status': 1}}),
        headers: {'content-type': 'application/json'},
      );

      final request = Request(
        'PUT',
        Uri.parse('http://localhost/todo/1'),
        body: jsonEncode({'title': 'Updated', 'status': 1}),
      );

      final response = await routes.router.call(request);

      expect(response.statusCode, equals(200));
    });

    test('should register DELETE /todo/<id> route', () async {
      mockHandler.deleteResponse = Response.ok(
        jsonEncode({'message': 'Todo deleted successfully', 'result': null}),
        headers: {'content-type': 'application/json'},
      );

      final request = Request(
        'DELETE',
        Uri.parse('http://localhost/todo/1'),
      );

      final response = await routes.router.call(request);

      expect(response.statusCode, equals(200));
    });

    test('should return 404 for undefined routes', () async {
      final request = Request(
        'GET',
        Uri.parse('http://localhost/undefined'),
      );

      final response = await routes.router.call(request);

      expect(response.statusCode, equals(404));
    });

    test('should return 404 for unsupported methods on defined routes', () async {
      final request = Request(
        'PATCH',
        Uri.parse('http://localhost/todo/1'),
      );

      final response = await routes.router.call(request);

      // shelf_router returns 404 for unsupported methods, not 405
      expect(response.statusCode, equals(404));
    });

    test('should handle route parameters correctly', () async {
      String? capturedId;

      mockHandler.getByIdCallback = (Request request, String id) async {
        capturedId = id;
        return Response.ok(
          jsonEncode({'result': {'id': int.parse(id), 'title': 'Test', 'status': 0}}),
          headers: {'content-type': 'application/json'},
        );
      };

      final request = Request(
        'GET',
        Uri.parse('http://localhost/todo/42'),
      );

      await routes.router.call(request);

      expect(capturedId, equals('42'));
    });
  });
}

// Mock DI for testing
class MockDI implements DI {
  final MockHandler _handler;

  MockDI(this._handler);

  @override
  HandlerImpl get handler => _handler;

  @override
  Repository get repository => throw UnimplementedError();

  @override
  Service get service => throw UnimplementedError();
}

// Mock Handler for testing
class MockHandler extends HandlerImpl {
  Response? createResponse;
  Response? getAllResponse;
  Response? getByIdResponse;
  Response? updateResponse;
  Response? deleteResponse;

  Future<Response> Function(Request, String)? getByIdCallback;
  Future<Response> Function(Request, String)? updateCallback;
  Future<Response> Function(Request, String)? deleteCallback;

  MockHandler() : super(MockService());

  @override
  Future<Response> create(Request request) async {
    return createResponse ?? Response.ok('{}');
  }

  @override
  Future<Response> getAll(Request request) async {
    return getAllResponse ?? Response.ok('{}');
  }

  @override
  Future<Response> getById(Request request, String id) async {
    if (getByIdCallback != null) {
      return getByIdCallback!(request, id);
    }
    return getByIdResponse ?? Response.ok('{}');
  }

  @override
  Future<Response> update(Request request, String id) async {
    if (updateCallback != null) {
      return updateCallback!(request, id);
    }
    return updateResponse ?? Response.ok('{}');
  }

  @override
  Future<Response> delete(Request request, String id) async {
    if (deleteCallback != null) {
      return deleteCallback!(request, id);
    }
    return deleteResponse ?? Response.ok('{}');
  }
}

// Mock Service for MockHandler
class MockService implements Service {
  @override
  Future<Todo> create(RequestTodo req) async {
    throw UnimplementedError();
  }

  @override
  Future<void> delete(int id) async {
    throw UnimplementedError();
  }

  @override
  Future<List<Todo>> getAll() async {
    throw UnimplementedError();
  }

  @override
  Future<Todo?> getById(int id) async {
    throw UnimplementedError();
  }

  @override
  Future<Todo> update(int id, RequestTodo req) async {
    throw UnimplementedError();
  }
}
