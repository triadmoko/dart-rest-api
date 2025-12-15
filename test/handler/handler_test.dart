import 'dart:convert';

import 'package:server/constants/constants.dart';
import 'package:server/dto/request.dart';
import 'package:server/handler/handler.dart';
import 'package:server/model/todo.dart';
import 'package:server/service/service.dart';
import 'package:server/tools/exception.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  group('HandlerImpl', () {
    late MockService mockService;
    late HandlerImpl handler;

    setUp(() {
      mockService = MockService();
      handler = HandlerImpl(mockService);
    });

    group('create', () {
      test('should return 200 with created todo', () async {
        final requestBody = jsonEncode({
          'title': 'New Todo',
          'status': 0,
        });

        final createdTodo = Todo.withId(
          id: 1,
          title: 'New Todo',
          status: TodoStatus.incomplete,
        );

        mockService.createResult = createdTodo;

        final request = Request(
          'POST',
          Uri.parse('http://localhost/todo'),
          body: requestBody,
        );

        final response = await handler.create(request);

        expect(response.statusCode, equals(200));
        expect(
          response.headers['content-type'],
          equals('application/json'),
        );

        final body = await response.readAsString();
        final json = jsonDecode(body);

        expect(json['result']['id'], equals(1));
        expect(json['result']['title'], equals('New Todo'));
        expect(json['result']['status'], equals(0));
      });

      test('should return 500 for validation error', () async {
        final requestBody = jsonEncode({
          'title': '',
          'status': 0,
        });

        final request = Request(
          'POST',
          Uri.parse('http://localhost/todo'),
          body: requestBody,
        );

        final response = await handler.create(request);

        expect(response.statusCode, equals(500));

        final body = await response.readAsString();
        final json = jsonDecode(body);

        expect(json['error'], equals('Title cannot be empty'));
        expect(json['result'], isNull);
      });

      test('should return 500 for missing fields', () async {
        final requestBody = jsonEncode({
          'title': 'Test Todo',
        });

        final request = Request(
          'POST',
          Uri.parse('http://localhost/todo'),
          body: requestBody,
        );

        final response = await handler.create(request);

        expect(response.statusCode, equals(500));

        final body = await response.readAsString();
        final json = jsonDecode(body);

        expect(json['error'], contains('Missing required field'));
        expect(json['result'], isNull);
      });

      test('should return 500 for service errors', () async {
        final requestBody = jsonEncode({
          'title': 'Test Todo',
          'status': 0,
        });

        mockService.createError = AppException('Database error');

        final request = Request(
          'POST',
          Uri.parse('http://localhost/todo'),
          body: requestBody,
        );

        final response = await handler.create(request);

        expect(response.statusCode, equals(500));

        final body = await response.readAsString();
        final json = jsonDecode(body);

        expect(json['error'], equals('Database error'));
        expect(json['result'], isNull);
      });

      test('should return 500 for invalid JSON', () async {
        final request = Request(
          'POST',
          Uri.parse('http://localhost/todo'),
          body: 'invalid json',
        );

        final response = await handler.create(request);

        expect(response.statusCode, equals(500));
      });
    });

    group('getAll', () {
      test('should return 200 with all todos', () async {
        final todos = [
          Todo.withId(id: 1, title: 'Todo 1', status: TodoStatus.incomplete),
          Todo.withId(id: 2, title: 'Todo 2', status: TodoStatus.complete),
        ];

        mockService.getAllResult = todos;

        final request = Request('GET', Uri.parse('http://localhost/todo'));

        final response = await handler.getAll(request);

        expect(response.statusCode, equals(200));
        expect(
          response.headers['content-type'],
          equals('application/json'),
        );

        final body = await response.readAsString();
        final json = jsonDecode(body);

        expect(json['result'], isA<List>());
        expect(json['result'].length, equals(2));
        expect(json['result'][0]['id'], equals(1));
        expect(json['result'][1]['id'], equals(2));
      });

      test('should return 200 with empty list when no todos', () async {
        mockService.getAllResult = [];

        final request = Request('GET', Uri.parse('http://localhost/todo'));

        final response = await handler.getAll(request);

        expect(response.statusCode, equals(200));

        final body = await response.readAsString();
        final json = jsonDecode(body);

        expect(json['result'], isA<List>());
        expect(json['result'], isEmpty);
      });

      test('should return 500 for service errors', () async {
        mockService.getAllError = AppException('Database error');

        final request = Request('GET', Uri.parse('http://localhost/todo'));

        final response = await handler.getAll(request);

        expect(response.statusCode, equals(500));

        final body = await response.readAsString();
        final json = jsonDecode(body);

        expect(json['error'], equals('Database error'));
        expect(json['result'], isNull);
      });
    });

    group('getById', () {
      test('should return 200 with todo when found', () async {
        final todo = Todo.withId(
          id: 1,
          title: 'Test Todo',
          status: TodoStatus.complete,
        );

        mockService.getByIdResult = todo;

        final request = Request('GET', Uri.parse('http://localhost/todo/1'));

        final response = await handler.getById(request, '1');

        expect(response.statusCode, equals(200));
        expect(
          response.headers['content-type'],
          equals('application/json'),
        );

        final body = await response.readAsString();
        final json = jsonDecode(body);

        expect(json['result']['id'], equals(1));
        expect(json['result']['title'], equals('Test Todo'));
        expect(json['result']['status'], equals(1));
      });

      test('should return 404 when todo not found', () async {
        mockService.getByIdResult = null;

        final request = Request('GET', Uri.parse('http://localhost/todo/999'));

        final response = await handler.getById(request, '999');

        expect(response.statusCode, equals(404));

        final body = await response.readAsString();
        final json = jsonDecode(body);

        expect(json['error'], equals('Todo with id 999 not found'));
        expect(json['result'], isNull);
      });

      test('should return 400 for invalid id format', () async {
        final request = Request('GET', Uri.parse('http://localhost/todo/abc'));

        final response = await handler.getById(request, 'abc');

        expect(response.statusCode, equals(400));

        final body = await response.readAsString();
        final json = jsonDecode(body);

        expect(json['error'], equals('Invalid id format'));
        expect(json['result'], isNull);
      });

      test('should return 500 for service errors', () async {
        mockService.getByIdError = AppException('Database error');

        final request = Request('GET', Uri.parse('http://localhost/todo/1'));

        final response = await handler.getById(request, '1');

        expect(response.statusCode, equals(500));

        final body = await response.readAsString();
        final json = jsonDecode(body);

        expect(json['error'], equals('Database error'));
        expect(json['result'], isNull);
      });
    });

    group('update', () {
      test('should return 200 with updated todo', () async {
        final requestBody = jsonEncode({
          'title': 'Updated Todo',
          'status': 1,
        });

        final updatedTodo = Todo.withId(
          id: 1,
          title: 'Updated Todo',
          status: TodoStatus.complete,
        );

        mockService.updateResult = updatedTodo;

        final request = Request(
          'PUT',
          Uri.parse('http://localhost/todo/1'),
          body: requestBody,
        );

        final response = await handler.update(request, '1');

        expect(response.statusCode, equals(200));
        expect(
          response.headers['content-type'],
          equals('application/json'),
        );

        final body = await response.readAsString();
        final json = jsonDecode(body);

        expect(json['result']['id'], equals(1));
        expect(json['result']['title'], equals('Updated Todo'));
        expect(json['result']['status'], equals(1));
      });

      test('should return 400 for invalid id format', () async {
        final requestBody = jsonEncode({
          'title': 'Updated Todo',
          'status': 1,
        });

        final request = Request(
          'PUT',
          Uri.parse('http://localhost/todo/abc'),
          body: requestBody,
        );

        final response = await handler.update(request, 'abc');

        expect(response.statusCode, equals(400));

        final body = await response.readAsString();
        final json = jsonDecode(body);

        expect(json['error'], equals('Invalid id format'));
        expect(json['result'], isNull);
      });

      test('should return 500 for validation errors', () async {
        final requestBody = jsonEncode({
          'title': '',
          'status': 1,
        });

        final request = Request(
          'PUT',
          Uri.parse('http://localhost/todo/1'),
          body: requestBody,
        );

        final response = await handler.update(request, '1');

        expect(response.statusCode, equals(500));

        final body = await response.readAsString();
        final json = jsonDecode(body);

        expect(json['error'], equals('Title cannot be empty'));
        expect(json['result'], isNull);
      });

      test('should return 500 when todo not found', () async {
        final requestBody = jsonEncode({
          'title': 'Updated Todo',
          'status': 1,
        });

        mockService.updateError = AppException('Todo with id 999 not found');

        final request = Request(
          'PUT',
          Uri.parse('http://localhost/todo/999'),
          body: requestBody,
        );

        final response = await handler.update(request, '999');

        expect(response.statusCode, equals(500));

        final body = await response.readAsString();
        final json = jsonDecode(body);

        expect(json['error'], contains('not found'));
        expect(json['result'], isNull);
      });
    });

    group('delete', () {
      test('should return 200 with success message', () async {
        final request = Request('DELETE', Uri.parse('http://localhost/todo/1'));

        final response = await handler.delete(request, '1');

        expect(response.statusCode, equals(200));
        expect(
          response.headers['content-type'],
          equals('application/json'),
        );

        final body = await response.readAsString();
        final json = jsonDecode(body);

        expect(json['message'], equals('Todo deleted successfully'));
        expect(json['result'], isNull);
      });

      test('should return 400 for invalid id format', () async {
        final request = Request(
          'DELETE',
          Uri.parse('http://localhost/todo/abc'),
        );

        final response = await handler.delete(request, 'abc');

        expect(response.statusCode, equals(400));

        final body = await response.readAsString();
        final json = jsonDecode(body);

        expect(json['error'], equals('Invalid id format'));
        expect(json['result'], isNull);
      });

      test('should return 500 when todo not found', () async {
        mockService.deleteError = AppException('Todo with id 999 not found');

        final request = Request(
          'DELETE',
          Uri.parse('http://localhost/todo/999'),
        );

        final response = await handler.delete(request, '999');

        expect(response.statusCode, equals(500));

        final body = await response.readAsString();
        final json = jsonDecode(body);

        expect(json['error'], contains('not found'));
        expect(json['result'], isNull);
      });
    });
  });
}

// Mock Service for testing
class MockService implements Service {
  Todo? createResult;
  List<Todo>? getAllResult;
  Todo? getByIdResult;
  Todo? updateResult;

  Exception? createError;
  Exception? getAllError;
  Exception? getByIdError;
  Exception? updateError;
  Exception? deleteError;

  @override
  Future<Todo> create(RequestTodo req) async {
    if (createError != null) {
      throw createError!;
    }
    return createResult!;
  }

  @override
  Future<List<Todo>> getAll() async {
    if (getAllError != null) {
      throw getAllError!;
    }
    return getAllResult!;
  }

  @override
  Future<Todo?> getById(int id) async {
    if (getByIdError != null) {
      throw getByIdError!;
    }
    return getByIdResult;
  }

  @override
  Future<Todo> update(int id, RequestTodo req) async {
    if (updateError != null) {
      throw updateError!;
    }
    return updateResult!;
  }

  @override
  Future<void> delete(int id) async {
    if (deleteError != null) {
      throw deleteError!;
    }
  }
}
