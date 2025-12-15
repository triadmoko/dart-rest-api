import 'dart:io';

import 'package:server/constants/constants.dart';
import 'package:server/model/todo.dart';
import 'package:server/repository/repository.dart';
import 'package:server/tools/exception.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

void main() {
  group('RepositoryImpl', () {
    late Database testDb;
    late RepositoryImpl repository;
    const testDbPath = './test_db.sqlite';

    setUp(() {
      // Create a test database
      testDb = sqlite3.open(testDbPath);
      testDb.execute('''
        CREATE TABLE IF NOT EXISTS todo (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          status INTEGER NOT NULL DEFAULT 0
        )
      ''');

      // Create a test repository with the test database
      repository = TestRepositoryImpl(testDb);
    });

    tearDown(() {
      // Clean up test database
      testDb.close();
      final file = File(testDbPath);
      if (file.existsSync()) {
        file.deleteSync();
      }
    });

    group('create', () {
      test('should create todo and return with id', () {
        final todo = Todo(
          title: 'Test Todo',
          status: TodoStatus.incomplete,
        );

        final result = repository.create(todo);

        expect(result.id, isNotNull);
        expect(result.id, greaterThan(0));
        expect(result.title, equals('Test Todo'));
        expect(result.status, equals(TodoStatus.incomplete));
      });

      test('should create multiple todos with different ids', () {
        final todo1 = Todo(
          title: 'First Todo',
          status: TodoStatus.incomplete,
        );
        final todo2 = Todo(
          title: 'Second Todo',
          status: TodoStatus.complete,
        );

        final result1 = repository.create(todo1);
        final result2 = repository.create(todo2);

        expect(result1.id, isNotNull);
        expect(result2.id, isNotNull);
        expect(result2.id, greaterThan(result1.id!));
      });

      test('should preserve status when creating', () {
        final incompleteTodo = Todo(
          title: 'Incomplete',
          status: TodoStatus.incomplete,
        );
        final completeTodo = Todo(
          title: 'Complete',
          status: TodoStatus.complete,
        );

        final result1 = repository.create(incompleteTodo);
        final result2 = repository.create(completeTodo);

        expect(result1.status, equals(TodoStatus.incomplete));
        expect(result2.status, equals(TodoStatus.complete));
      });
    });

    group('getAll', () {
      test('should return empty list when no todos exist', () {
        final result = repository.getAll();

        expect(result, isEmpty);
      });

      test('should return all todos', () {
        final todo1 = Todo(title: 'Todo 1', status: TodoStatus.incomplete);
        final todo2 = Todo(title: 'Todo 2', status: TodoStatus.complete);

        repository.create(todo1);
        repository.create(todo2);

        final result = repository.getAll();

        expect(result.length, equals(2));
      });

      test('should return todos in descending order by id', () {
        final todo1 = repository.create(
          Todo(title: 'First', status: TodoStatus.incomplete),
        );
        final todo2 = repository.create(
          Todo(title: 'Second', status: TodoStatus.complete),
        );
        final todo3 = repository.create(
          Todo(title: 'Third', status: TodoStatus.incomplete),
        );

        final result = repository.getAll();

        expect(result[0].id, equals(todo3.id));
        expect(result[1].id, equals(todo2.id));
        expect(result[2].id, equals(todo1.id));
      });

      test('should preserve all todo properties', () {
        repository.create(
          Todo(title: 'Test Todo', status: TodoStatus.complete),
        );

        final result = repository.getAll();

        expect(result.first.title, equals('Test Todo'));
        expect(result.first.status, equals(TodoStatus.complete));
      });
    });

    group('getById', () {
      test('should return todo when found', () {
        final created = repository.create(
          Todo(title: 'Test Todo', status: TodoStatus.incomplete),
        );

        final result = repository.getById(created.id!);

        expect(result, isNotNull);
        expect(result!.id, equals(created.id));
        expect(result.title, equals('Test Todo'));
        expect(result.status, equals(TodoStatus.incomplete));
      });

      test('should return null when todo not found', () {
        final result = repository.getById(999);

        expect(result, isNull);
      });

      test('should return correct todo when multiple exist', () {
        repository.create(Todo(title: 'First', status: TodoStatus.incomplete));
        final second = repository.create(
          Todo(title: 'Second', status: TodoStatus.complete),
        );
        repository.create(Todo(title: 'Third', status: TodoStatus.incomplete));

        final result = repository.getById(second.id!);

        expect(result, isNotNull);
        expect(result!.title, equals('Second'));
        expect(result.status, equals(TodoStatus.complete));
      });
    });

    group('update', () {
      test('should update todo successfully', () {
        final created = repository.create(
          Todo(title: 'Original', status: TodoStatus.incomplete),
        );

        final updated = Todo(
          title: 'Updated',
          status: TodoStatus.complete,
        );

        final result = repository.update(created.id!, updated);

        expect(result.id, equals(created.id));
        expect(result.title, equals('Updated'));
        expect(result.status, equals(TodoStatus.complete));
      });

      test('should persist updated values', () {
        final created = repository.create(
          Todo(title: 'Original', status: TodoStatus.incomplete),
        );

        final updated = Todo(
          title: 'Updated',
          status: TodoStatus.complete,
        );

        repository.update(created.id!, updated);

        final fetched = repository.getById(created.id!);

        expect(fetched!.title, equals('Updated'));
        expect(fetched.status, equals(TodoStatus.complete));
      });

      test('should throw AppException when todo not found', () {
        final todo = Todo(
          title: 'Test',
          status: TodoStatus.incomplete,
        );

        expect(
          () => repository.update(999, todo),
          throwsA(
            isA<AppException>().having(
              (e) => e.message,
              'message',
              contains('Todo with id 999 not found'),
            ),
          ),
        );
      });

      test('should only update specified todo', () {
        final first = repository.create(
          Todo(title: 'First', status: TodoStatus.incomplete),
        );
        final second = repository.create(
          Todo(title: 'Second', status: TodoStatus.incomplete),
        );

        repository.update(
          first.id!,
          Todo(title: 'Updated First', status: TodoStatus.complete),
        );

        final firstResult = repository.getById(first.id!);
        final secondResult = repository.getById(second.id!);

        expect(firstResult!.title, equals('Updated First'));
        expect(secondResult!.title, equals('Second'));
      });
    });

    group('delete', () {
      test('should delete todo successfully', () {
        final created = repository.create(
          Todo(title: 'To Delete', status: TodoStatus.incomplete),
        );

        repository.delete(created.id!);

        final result = repository.getById(created.id!);
        expect(result, isNull);
      });

      test('should throw AppException when todo not found', () {
        expect(
          () => repository.delete(999),
          throwsA(
            isA<AppException>().having(
              (e) => e.message,
              'message',
              contains('Todo with id 999 not found'),
            ),
          ),
        );
      });

      test('should only delete specified todo', () {
        final first = repository.create(
          Todo(title: 'First', status: TodoStatus.incomplete),
        );
        final second = repository.create(
          Todo(title: 'Second', status: TodoStatus.incomplete),
        );

        repository.delete(first.id!);

        final firstResult = repository.getById(first.id!);
        final secondResult = repository.getById(second.id!);

        expect(firstResult, isNull);
        expect(secondResult, isNotNull);
      });

      test('should update getAll after deletion', () {
        final first = repository.create(
          Todo(title: 'First', status: TodoStatus.incomplete),
        );
        repository.create(Todo(title: 'Second', status: TodoStatus.incomplete));

        repository.delete(first.id!);

        final allTodos = repository.getAll();
        expect(allTodos.length, equals(1));
        expect(allTodos.first.title, equals('Second'));
      });
    });
  });
}

// Test implementation that uses injected database instead of singleton
class TestRepositoryImpl extends RepositoryImpl {
  final Database _testDb;

  TestRepositoryImpl(this._testDb);

  @override
  Database get db => _testDb;
}
