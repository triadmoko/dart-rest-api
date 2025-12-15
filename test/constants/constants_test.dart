import 'package:server/constants/constants.dart';
import 'package:test/test.dart';

void main() {
  group('TodoStatus', () {
    test('should have correct values', () {
      expect(TodoStatus.incomplete.value, equals(0));
      expect(TodoStatus.complete.value, equals(1));
    });

    test('fromValue should return correct status for valid values', () {
      expect(TodoStatus.fromValue(0), equals(TodoStatus.incomplete));
      expect(TodoStatus.fromValue(1), equals(TodoStatus.complete));
    });

    test('fromValue should throw ArgumentError for invalid values', () {
      expect(
        () => TodoStatus.fromValue(2),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => TodoStatus.fromValue(-1),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => TodoStatus.fromValue(999),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('toJson should return integer value', () {
      expect(TodoStatus.incomplete.toJson(), equals(0));
      expect(TodoStatus.complete.toJson(), equals(1));
    });
  });

  group('ValidationConfig', () {
    test('should have correct max title length', () {
      expect(ValidationConfig.maxTitleLength, equals(255));
    });

    test('should have correct min title length', () {
      expect(ValidationConfig.minTitleLength, equals(1));
    });
  });

  group('DbConfig', () {
    test('should have correct database path', () {
      expect(DbConfig.dbPath, equals('./db.sqlite'));
    });
  });
}
