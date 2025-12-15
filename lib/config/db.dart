import 'package:server/constants/constants.dart';
import 'package:sqlite3/sqlite3.dart';

/// Database singleton for managing SQLite connections.
///
/// Provides a single shared database instance across the application.
/// Automatically initializes the schema on first access.
class DB {
  /// Singleton instance.
  static final DB instance = DB._();

  /// The SQLite database connection.
  late final Database database = _initDatabase();

  /// Private constructor to prevent external instantiation.
  DB._();

  /// Initializes the database connection and schema.
  Database _initDatabase() {
    final db = sqlite3.open(DbConfig.dbPath);
    _initializeSchema(db);
    return db;
  }

  /// Creates the database tables if they don't exist.
  ///
  /// Creates the 'todo' table with columns:
  /// - id: INTEGER PRIMARY KEY AUTOINCREMENT
  /// - title: TEXT NOT NULL
  /// - status: INTEGER NOT NULL DEFAULT 0
  void _initializeSchema(Database db) {
    db.execute('''
      CREATE TABLE IF NOT EXISTS todo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        status INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  /// Closes the database connection.
  ///
  /// Should be called when shutting down the application.
  void closeConnection() {
    database.close();
  }
}
