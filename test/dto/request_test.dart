import 'package:server/constants/constants.dart';
import 'package:server/dto/request.dart';
import 'package:server/model/todo.dart';
import 'package:server/tools/exception.dart';
import 'package:test/test.dart';

void main() {
  group('RequestTodo', () {
    group('constructor validation', () {
      test('should create valid RequestTodo', () {
        final request = RequestTodo(
          title: 'Valid Title',
          status: TodoStatus.incomplete,
        );

        expect(request.title, equals('Valid Title'));
        expect(request.status, equals(TodoStatus.incomplete));
      });

      test('should throw AppException for empty title', () {
        expect(
          () => RequestTodo(
            title: '',
            status: TodoStatus.incomplete,
          ),
          throwsA(
            isA<AppException>().having(
              (e) => e.message,
              'message',
              equals('Title cannot be empty'),
            ),
          ),
        );
      });

      test('should throw AppException for whitespace-only title', () {
        expect(
          () => RequestTodo(
            title: '   ',
            status: TodoStatus.incomplete,
          ),
          throwsA(
            isA<AppException>().having(
              (e) => e.message,
              'message',
              equals('Title cannot be empty'),
            ),
          ),
        );
      });

      test('should throw AppException for title exceeding max length', () {
        final longTitle = 'a' * 256; // Exceeds 255 max length

        expect(
          () => RequestTodo(
            title: longTitle,
            status: TodoStatus.incomplete,
          ),
          throwsA(
            isA<AppException>().having(
              (e) => e.message,
              'message',
              equals('Title cannot exceed 255 characters'),
            ),
          ),
        );
      });

      test('should accept title at max length boundary', () {
        final maxTitle = 'a' * 255; // Exactly at max length

        final request = RequestTodo(
          title: maxTitle,
          status: TodoStatus.incomplete,
        );

        expect(request.title, equals(maxTitle));
      });

      test('should accept title with leading/trailing spaces if not empty after trim', () {
        final request = RequestTodo(
          title: '  Valid Title  ',
          status: TodoStatus.complete,
        );

        expect(request.title, equals('  Valid Title  '));
      });
    });

    group('fromJson', () {
      test('should create RequestTodo from valid JSON', () {
        final json = {
          'title': 'Test Todo',
          'status': 0,
        };

        final request = RequestTodo.fromJson(json);

        expect(request.title, equals('Test Todo'));
        expect(request.status, equals(TodoStatus.incomplete));
      });

      test('should create RequestTodo with complete status', () {
        final json = {
          'title': 'Completed Task',
          'status': 1,
        };

        final request = RequestTodo.fromJson(json);

        expect(request.title, equals('Completed Task'));
        expect(request.status, equals(TodoStatus.complete));
      });

      test('should throw AppException when title is missing', () {
        final json = {
          'status': 0,
        };

        expect(
          () => RequestTodo.fromJson(json),
          throwsA(
            isA<AppException>().having(
              (e) => e.message,
              'message',
              equals('Missing required field: title'),
            ),
          ),
        );
      });

      test('should throw AppException when status is missing', () {
        final json = {
          'title': 'Test Todo',
        };

        expect(
          () => RequestTodo.fromJson(json),
          throwsA(
            isA<AppException>().having(
              (e) => e.message,
              'message',
              equals('Missing required field: status'),
            ),
          ),
        );
      });

      test('should throw AppException when title is not a string', () {
        final json = {
          'title': 123,
          'status': 0,
        };

        expect(
          () => RequestTodo.fromJson(json),
          throwsA(
            isA<AppException>().having(
              (e) => e.message,
              'message',
              equals('Field "title" must be a string'),
            ),
          ),
        );
      });

      test('should throw AppException when status is not an integer', () {
        final json = {
          'title': 'Test Todo',
          'status': 'incomplete',
        };

        expect(
          () => RequestTodo.fromJson(json),
          throwsA(
            isA<AppException>().having(
              (e) => e.message,
              'message',
              equals('Field "status" must be an integer'),
            ),
          ),
        );
      });

      test('should throw ArgumentError for invalid status value', () {
        final json = {
          'title': 'Test Todo',
          'status': 99,
        };

        expect(
          () => RequestTodo.fromJson(json),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should still validate title from JSON', () {
        final json = {
          'title': '',
          'status': 0,
        };

        expect(
          () => RequestTodo.fromJson(json),
          throwsA(
            isA<AppException>().having(
              (e) => e.message,
              'message',
              equals('Title cannot be empty'),
            ),
          ),
        );
      });

      test('should handle special characters in JSON title', () {
        final json = {
          'title': 'Todo with "quotes" and \n newlines',
          'status': 0,
        };

        final request = RequestTodo.fromJson(json);

        expect(request.title, equals('Todo with "quotes" and \n newlines'));
      });
    });

    group('toModel', () {
      test('should convert to Todo model', () {
        final request = RequestTodo(
          title: 'Test Todo',
          status: TodoStatus.incomplete,
        );

        final todo = request.toModel();

        expect(todo, isA<Todo>());
        expect(todo.id, isNull);
        expect(todo.title, equals('Test Todo'));
        expect(todo.status, equals(TodoStatus.incomplete));
      });

      test('should convert complete status correctly', () {
        final request = RequestTodo(
          title: 'Completed Task',
          status: TodoStatus.complete,
        );

        final todo = request.toModel();

        expect(todo.status, equals(TodoStatus.complete));
      });

      test('should preserve title exactly as provided', () {
        final request = RequestTodo(
          title: '  Title with spaces  ',
          status: TodoStatus.incomplete,
        );

        final todo = request.toModel();

        expect(todo.title, equals('  Title with spaces  '));
      });
    });
  });
}
