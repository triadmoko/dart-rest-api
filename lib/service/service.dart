import 'package:server/dto/request.dart';
import 'package:server/model/todo.dart';
import 'package:server/repository/repository.dart';
import 'package:server/tools/exception.dart';

/// Service interface for business logic.
abstract class Service {
  /// Creates a new todo.
  Future<Todo> create(RequestTodo req);

  /// Retrieves all todos.
  Future<List<Todo>> getAll();

  /// Retrieves a todo by ID.
  Future<Todo?> getById(int id);

  /// Updates an existing todo.
  Future<Todo> update(int id, RequestTodo req);

  /// Deletes a todo by ID.
  Future<void> delete(int id);
}

/// Service implementation with error handling.
class ServiceImpl with ErrorHandler implements Service {
  /// Repository for data access.
  final Repository _repository;

  ServiceImpl(this._repository);

  @override
  Future<Todo> create(RequestTodo req) async {
    final todo = req.toModel();
    return safeExecute(
      () => _repository.create(todo),
      errorMessage: 'Failed to create todo',
    );
  }

  @override
  Future<List<Todo>> getAll() async {
    return safeExecute(
      () => _repository.getAll(),
      errorMessage: 'Failed to get all todos',
    );
  }

  @override
  Future<Todo?> getById(int id) async {
    return safeExecute(
      () => _repository.getById(id),
      errorMessage: 'Failed to get todo by id',
    );
  }

  @override
  Future<Todo> update(int id, RequestTodo req) async {
    final todo = req.toModel();
    return safeExecute(
      () => _repository.update(id, todo),
      errorMessage: 'Failed to update todo',
    );
  }

  @override
  Future<void> delete(int id) async {
    safeExecute(
      () => _repository.delete(id),
      errorMessage: 'Failed to delete todo',
    );
  }
}
