import 'package:server/constants/constants.dart';
import 'package:server/dto/request.dart';
import 'package:server/model/todo.dart';
import 'package:server/repository/repository.dart';
import 'package:server/service/service.dart';
import 'package:server/tools/exception.dart';
import 'package:test/test.dart';

void main() {
  group('ServiceImpl', () {
    late MockRepository mockRepository;
    late Service service;

    setUp(() {
      mockRepository = MockRepository();
      service = ServiceImpl(mockRepository);
    });

    group('create', () {
      test('should create todo successfully', () async {
        final request = RequestTodo(
          title: 'Test Todo',
          status: TodoStatus.incomplete,
        );

        final expectedTodo = Todo.withId(
          id: 1,
          title: 'Test Todo',
          status: TodoStatus.incomplete,
        );

        mockRepository.createResult = expectedTodo;

        final result = await service.create(request);

        expect(result, equals(expectedTodo));
        expect(mockRepository.createCalled, isTrue);
        expect(mockRepository.lastCreatedTodo?.title, equals('Test Todo'));
        expect(mockRepository.lastCreatedTodo?.status, equals(TodoStatus.incomplete));
      });

      test('should propagate AppException from repository', () async {
        final request = RequestTodo(
          title: 'Test Todo',
          status: TodoStatus.incomplete,
        );

        mockRepository.createError = AppException('Database error');

        expect(
          () => service.create(request),
          throwsA(isA<AppException>()),
        );
      });

      test('should wrap non-AppException errors', () async {
        final request = RequestTodo(
          title: 'Test Todo',
          status: TodoStatus.incomplete,
        );

        mockRepository.createError = Exception('Unexpected error');

        expect(
          () => service.create(request),
          throwsA(
            isA<AppException>().having(
              (e) => e.message,
              'message',
              contains('Failed to create todo'),
            ),
          ),
        );
      });
    });

    group('getAll', () {
      test('should return all todos', () async {
        final todos = [
          Todo.withId(id: 1, title: 'Todo 1', status: TodoStatus.incomplete),
          Todo.withId(id: 2, title: 'Todo 2', status: TodoStatus.complete),
        ];

        mockRepository.getAllResult = todos;

        final result = await service.getAll();

        expect(result, equals(todos));
        expect(result.length, equals(2));
        expect(mockRepository.getAllCalled, isTrue);
      });

      test('should return empty list when no todos exist', () async {
        mockRepository.getAllResult = [];

        final result = await service.getAll();

        expect(result, isEmpty);
        expect(mockRepository.getAllCalled, isTrue);
      });

      test('should propagate errors from repository', () async {
        mockRepository.getAllError = Exception('Database error');

        expect(
          () => service.getAll(),
          throwsA(
            isA<AppException>().having(
              (e) => e.message,
              'message',
              contains('Failed to get all todos'),
            ),
          ),
        );
      });
    });

    group('getById', () {
      test('should return todo when found', () async {
        final todo = Todo.withId(
          id: 1,
          title: 'Test Todo',
          status: TodoStatus.complete,
        );

        mockRepository.getByIdResult = todo;

        final result = await service.getById(1);

        expect(result, equals(todo));
        expect(mockRepository.getByIdCalled, isTrue);
        expect(mockRepository.lastGetByIdParam, equals(1));
      });

      test('should return null when todo not found', () async {
        mockRepository.getByIdResult = null;

        final result = await service.getById(999);

        expect(result, isNull);
        expect(mockRepository.getByIdCalled, isTrue);
        expect(mockRepository.lastGetByIdParam, equals(999));
      });

      test('should propagate errors from repository', () async {
        mockRepository.getByIdError = Exception('Database error');

        expect(
          () => service.getById(1),
          throwsA(
            isA<AppException>().having(
              (e) => e.message,
              'message',
              contains('Failed to get todo by id'),
            ),
          ),
        );
      });
    });

    group('update', () {
      test('should update todo successfully', () async {
        final request = RequestTodo(
          title: 'Updated Todo',
          status: TodoStatus.complete,
        );

        final expectedTodo = Todo.withId(
          id: 1,
          title: 'Updated Todo',
          status: TodoStatus.complete,
        );

        mockRepository.updateResult = expectedTodo;

        final result = await service.update(1, request);

        expect(result, equals(expectedTodo));
        expect(mockRepository.updateCalled, isTrue);
        expect(mockRepository.lastUpdateIdParam, equals(1));
        expect(mockRepository.lastUpdatedTodo?.title, equals('Updated Todo'));
        expect(mockRepository.lastUpdatedTodo?.status, equals(TodoStatus.complete));
      });

      test('should propagate not found error from repository', () async {
        final request = RequestTodo(
          title: 'Updated Todo',
          status: TodoStatus.complete,
        );

        mockRepository.updateError = AppException('Todo with id 999 not found');

        expect(
          () => service.update(999, request),
          throwsA(isA<AppException>()),
        );
      });

      test('should wrap unexpected errors', () async {
        final request = RequestTodo(
          title: 'Updated Todo',
          status: TodoStatus.complete,
        );

        mockRepository.updateError = Exception('Database error');

        expect(
          () => service.update(1, request),
          throwsA(
            isA<AppException>().having(
              (e) => e.message,
              'message',
              contains('Failed to update todo'),
            ),
          ),
        );
      });
    });

    group('delete', () {
      test('should delete todo successfully', () async {
        await service.delete(1);

        expect(mockRepository.deleteCalled, isTrue);
        expect(mockRepository.lastDeleteIdParam, equals(1));
      });

      test('should propagate not found error from repository', () async {
        mockRepository.deleteError = AppException('Todo with id 999 not found');

        expect(
          () => service.delete(999),
          throwsA(isA<AppException>()),
        );
      });

      test('should wrap unexpected errors', () async {
        mockRepository.deleteError = Exception('Database error');

        expect(
          () => service.delete(1),
          throwsA(
            isA<AppException>().having(
              (e) => e.message,
              'message',
              contains('Failed to delete todo'),
            ),
          ),
        );
      });
    });
  });
}

// Mock Repository for testing
class MockRepository implements Repository {
  bool createCalled = false;
  bool getAllCalled = false;
  bool getByIdCalled = false;
  bool updateCalled = false;
  bool deleteCalled = false;

  Todo? lastCreatedTodo;
  int? lastGetByIdParam;
  int? lastUpdateIdParam;
  Todo? lastUpdatedTodo;
  int? lastDeleteIdParam;

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
  Todo create(Todo todo) {
    createCalled = true;
    lastCreatedTodo = todo;

    if (createError != null) {
      throw createError!;
    }

    return createResult!;
  }

  @override
  List<Todo> getAll() {
    getAllCalled = true;

    if (getAllError != null) {
      throw getAllError!;
    }

    return getAllResult!;
  }

  @override
  Todo? getById(int id) {
    getByIdCalled = true;
    lastGetByIdParam = id;

    if (getByIdError != null) {
      throw getByIdError!;
    }

    return getByIdResult;
  }

  @override
  Todo update(int id, Todo todo) {
    updateCalled = true;
    lastUpdateIdParam = id;
    lastUpdatedTodo = todo;

    if (updateError != null) {
      throw updateError!;
    }

    return updateResult!;
  }

  @override
  void delete(int id) {
    deleteCalled = true;
    lastDeleteIdParam = id;

    if (deleteError != null) {
      throw deleteError!;
    }
  }
}
