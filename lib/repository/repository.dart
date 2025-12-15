import 'package:server/config/db.dart';
import 'package:server/constants/constants.dart';
import 'package:server/model/todo.dart';
import 'package:server/tools/exception.dart';

/// Repository interface for todo data access.
abstract class Repository {
  /// Creates a new todo in the database.
  Todo create(Todo todo);

  /// Retrieves all todos from the database.
  List<Todo> getAll();

  /// Retrieves a todo by its ID.
  ///
  /// Returns null if not found.
  Todo? getById(int id);

  /// Updates an existing todo.
  ///
  /// Throws [AppException] if todo not found.
  Todo update(int id, Todo todo);

  /// Deletes a todo by its ID.
  ///
  /// Throws [AppException] if todo not found.
  void delete(int id);
}

/// Repository implementation using SQLite.
class RepositoryImpl with ErrorHandler implements Repository {
  /// Database instance.
  final db = DB.instance.database;

  @override
  Todo create(Todo todo) {
    return safeExecute(() {
      final stmt = db.prepare('INSERT INTO todo (title, status) VALUES (?, ?)');
      stmt.execute([todo.title, todo.status.value]);
      stmt.close();

      final id = db.lastInsertRowId;
      return Todo.withId(id: id, title: todo.title, status: todo.status);
    }, errorMessage: 'Failed to create todo');
  }

  @override
  List<Todo> getAll() {
    return safeExecute(() {
      final stmt = db.prepare('SELECT id, title, status FROM todo ORDER BY id DESC');
      final result = stmt.select();
      stmt.close();

      return result.map((row) {
        return Todo.withId(
          id: row['id'] as int,
          title: row['title'] as String,
          status: TodoStatus.fromValue(row['status'] as int),
        );
      }).toList();
    }, errorMessage: 'Failed to get all todos');
  }

  @override
  Todo? getById(int id) {
    return safeExecute(() {
      final stmt = db.prepare('SELECT id, title, status FROM todo WHERE id = ?');
      final result = stmt.select([id]);
      stmt.close();

      if (result.isEmpty) {
        return null;
      }

      final row = result.first;
      return Todo.withId(
        id: row['id'] as int,
        title: row['title'] as String,
        status: TodoStatus.fromValue(row['status'] as int),
      );
    }, errorMessage: 'Failed to get todo by id');
  }

  @override
  Todo update(int id, Todo todo) {
    return safeExecute(() {
      final stmt = db.prepare('UPDATE todo SET title = ?, status = ? WHERE id = ?');
      stmt.execute([todo.title, todo.status.value, id]);
      stmt.close();

      final changes = db.updatedRows;

      if (changes == 0) {
        throw AppException('Todo with id $id not found');
      }

      return Todo.withId(id: id, title: todo.title, status: todo.status);
    }, errorMessage: 'Failed to update todo');
  }

  @override
  void delete(int id) {
    safeExecute(() {
      final stmt = db.prepare('DELETE FROM todo WHERE id = ?');
      stmt.execute([id]);
      stmt.close();

      final changes = db.updatedRows;

      if (changes == 0) {
        throw AppException('Todo with id $id not found');
      }
    }, errorMessage: 'Failed to delete todo');
  }
}
