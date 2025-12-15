import 'package:server/constants/constants.dart';
import 'package:server/model/todo.dart';
import 'package:test/test.dart';

void main() {
  group('Todo', () {
    group('constructor', () {
      test('should create todo without id', () {
        final todo = Todo(
          title: 'Test Todo',
          status: TodoStatus.incomplete,
        );

        expect(todo.id, isNull);
        expect(todo.title, equals('Test Todo'));
        expect(todo.status, equals(TodoStatus.incomplete));
      });
    });

    group('withId constructor', () {
      test('should create todo with id', () {
        final todo = Todo.withId(
          id: 1,
          title: 'Test Todo',
          status: TodoStatus.complete,
        );

        expect(todo.id, equals(1));
        expect(todo.title, equals('Test Todo'));
        expect(todo.status, equals(TodoStatus.complete));
      });

      test('should create todo with different statuses', () {
        final incompleteTodo = Todo.withId(
          id: 1,
          title: 'Incomplete Task',
          status: TodoStatus.incomplete,
        );
        final completeTodo = Todo.withId(
          id: 2,
          title: 'Complete Task',
          status: TodoStatus.complete,
        );

        expect(incompleteTodo.status, equals(TodoStatus.incomplete));
        expect(completeTodo.status, equals(TodoStatus.complete));
      });
    });

    group('toJson', () {
      test('should convert todo without id to json', () {
        final todo = Todo(
          title: 'Test Todo',
          status: TodoStatus.incomplete,
        );

        final json = todo.toJson();

        expect(json, isA<Map<String, dynamic>>());
        expect(json['id'], isNull);
        expect(json['title'], equals('Test Todo'));
        expect(json['status'], equals(0));
      });

      test('should convert todo with id to json', () {
        final todo = Todo.withId(
          id: 42,
          title: 'Complete Todo',
          status: TodoStatus.complete,
        );

        final json = todo.toJson();

        expect(json, isA<Map<String, dynamic>>());
        expect(json['id'], equals(42));
        expect(json['title'], equals('Complete Todo'));
        expect(json['status'], equals(1));
      });

      test('should handle special characters in title', () {
        final todo = Todo.withId(
          id: 1,
          title: 'Test with "quotes" and \n newlines',
          status: TodoStatus.incomplete,
        );

        final json = todo.toJson();

        expect(json['title'], equals('Test with "quotes" and \n newlines'));
      });
    });

    group('toString', () {
      test('should return formatted string representation', () {
        final todo = Todo.withId(
          id: 1,
          title: 'Test Todo',
          status: TodoStatus.incomplete,
        );

        expect(
          todo.toString(),
          equals('Todo(id: 1, title: Test Todo, status: TodoStatus.incomplete)'),
        );
      });

      test('should handle null id in string representation', () {
        final todo = Todo(
          title: 'Test Todo',
          status: TodoStatus.complete,
        );

        expect(
          todo.toString(),
          equals('Todo(id: null, title: Test Todo, status: TodoStatus.complete)'),
        );
      });
    });
  });
}
