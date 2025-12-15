import 'package:server/constants/constants.dart';
import 'package:server/model/todo.dart';
import 'package:server/tools/exception.dart';

/// Data Transfer Object for todo creation/update requests.
///
/// Validates input data before converting to domain model.
class RequestTodo {
  /// The title of the todo.
  final String title;

  /// The status of the todo.
  final TodoStatus status;

  /// Creates a [RequestTodo] with validation.
  ///
  /// Throws [AppException] if validation fails.
  RequestTodo({
    required this.title,
    required this.status,
  }) {
    _validate();
  }

  /// Validates the todo data.
  ///
  /// Throws [AppException] if validation fails.
  void _validate() {
    if (title.trim().isEmpty) {
      throw AppException('Title cannot be empty');
    }
    if (title.length > ValidationConfig.maxTitleLength) {
      throw AppException(
        'Title cannot exceed ${ValidationConfig.maxTitleLength} characters',
      );
    }
  }

  /// Converts this DTO to a domain model.
  Todo toModel() {
    return Todo(title: title, status: status);
  }

  /// Creates a [RequestTodo] from a JSON object.
  ///
  /// Validates JSON structure and types.
  /// Throws [AppException] if validation fails.
  static RequestTodo fromJson(Json json) {
    // Validate JSON structure
    if (!json.containsKey('title')) {
      throw AppException('Missing required field: title');
    }
    if (!json.containsKey('status')) {
      throw AppException('Missing required field: status');
    }

    // Validate types
    if (json['title'] is! String) {
      throw AppException('Field "title" must be a string');
    }
    if (json['status'] is! int) {
      throw AppException('Field "status" must be an integer');
    }

    return RequestTodo(
      title: json['title'] as String,
      status: TodoStatus.fromValue(json['status'] as int),
    );
  }
}
