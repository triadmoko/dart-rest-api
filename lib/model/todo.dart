import 'package:server/constants/constants.dart';

/// Represents a todo item in the system.
///
/// A todo has a [title] describing the task and a [status]
/// indicating completion state (incomplete or complete).
class Todo {
  /// Unique identifier for this todo.
  ///
  /// Null if the todo hasn't been persisted to the database yet.
  final int? id;

  /// Description of the task.
  final String title;

  /// Completion status of this todo.
  final TodoStatus status;

  /// Creates a new [Todo] without an ID.
  ///
  /// Used when creating a new todo before persisting to database.
  const Todo({
    required this.title,
    required this.status,
  }) : id = null;

  /// Creates a [Todo] with all fields including [id].
  ///
  /// Used when retrieving todos from the database.
  const Todo.withId({
    required this.id,
    required this.title,
    required this.status,
  });

  /// Converts this todo to a JSON object.
  Json toJson() => {
        'id': id,
        'title': title,
        'status': status.toJson(),
      };

  @override
  String toString() => 'Todo(id: $id, title: $title, status: $status)';
}
