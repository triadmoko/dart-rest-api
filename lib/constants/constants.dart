/// Database configuration constants.
class DbConfig {
  /// Path to the SQLite database file.
  static const String dbPath = './db.sqlite';
}

/// Validation constants for todo items.
class ValidationConfig {
  /// Maximum length for todo title.
  static const int maxTitleLength = 255;

  /// Minimum length for todo title (after trimming).
  static const int minTitleLength = 1;
}

/// Type alias for JSON objects.
typedef Json = Map<String, dynamic>;

/// Todo status enum representing completion state.
enum TodoStatus {
  /// Todo is not yet completed.
  incomplete(0),

  /// Todo is completed.
  complete(1);

  /// The integer value representing this status.
  final int value;

  const TodoStatus(this.value);

  /// Creates a [TodoStatus] from an integer value.
  ///
  /// Throws [ArgumentError] if the value is not valid.
  static TodoStatus fromValue(int value) {
    return TodoStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => throw ArgumentError('Invalid status value: $value'),
    );
  }

  /// Converts this status to JSON-compatible format.
  int toJson() => value;
}
