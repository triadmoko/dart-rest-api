import 'package:server/tools/exception.dart';
import 'package:test/test.dart';

void main() {
  group('AppException', () {
    test('should create exception with message only', () {
      final exception = AppException('Test error');

      expect(exception.message, equals('Test error'));
      expect(exception.originalError, isNull);
    });

    test('should create exception with message and original error', () {
      final originalError = Exception('Original error');
      final exception = AppException('Wrapped error', originalError);

      expect(exception.message, equals('Wrapped error'));
      expect(exception.originalError, equals(originalError));
    });

    test('toString should return formatted message', () {
      final exception = AppException('Test error');

      expect(exception.toString(), equals('AppException: Test error'));
    });

    test('should be throwable', () {
      expect(
        () => throw AppException('Test error'),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('ErrorHandler', () {
    late TestErrorHandler handler;

    setUp(() {
      handler = TestErrorHandler();
    });

    group('safeExecute', () {
      test('should return result when action succeeds', () {
        final result = handler.safeExecute(() => 42);

        expect(result, equals(42));
      });

      test('should return string result when action succeeds', () {
        final result = handler.safeExecute(() => 'success');

        expect(result, equals('success'));
      });

      test('should wrap exception in AppException with default message', () {
        expect(
          () => handler.safeExecute(() => throw Exception('Test error')),
          throwsA(
            isA<AppException>()
                .having(
                  (e) => e.message,
                  'message',
                  contains('An error occurred'),
                )
                .having(
                  (e) => e.message,
                  'message',
                  contains('Test error'),
                ),
          ),
        );
      });

      test('should wrap exception in AppException with custom error message', () {
        expect(
          () => handler.safeExecute(
            () => throw Exception('Test error'),
            errorMessage: 'Custom error',
          ),
          throwsA(
            isA<AppException>()
                .having(
                  (e) => e.message,
                  'message',
                  contains('Custom error'),
                )
                .having(
                  (e) => e.message,
                  'message',
                  contains('Test error'),
                ),
          ),
        );
      });

      test('should preserve original exception if it is an Exception', () {
        final originalException = Exception('Original');

        try {
          handler.safeExecute(() => throw originalException);
          fail('Should have thrown AppException');
        } catch (e) {
          expect(e, isA<AppException>());
          expect((e as AppException).originalError, equals(originalException));
        }
      });

      test('should handle non-Exception errors', () {
        expect(
          () => handler.safeExecute(() => throw 'String error'),
          throwsA(
            isA<AppException>()
                .having(
                  (e) => e.message,
                  'message',
                  contains('String error'),
                )
                .having(
                  (e) => e.originalError,
                  'originalError',
                  isNull,
                ),
          ),
        );
      });

      test('should handle StateError', () {
        expect(
          () => handler.safeExecute(() => throw StateError('State error')),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('safeExecuteAsync', () {
      test('should return result when async action succeeds', () async {
        final result = await handler.safeExecuteAsync(() async => 42);

        expect(result, equals(42));
      });

      test('should return string result when async action succeeds', () async {
        final result = await handler.safeExecuteAsync(() async => 'success');

        expect(result, equals('success'));
      });

      test('should handle delayed results', () async {
        final result = await handler.safeExecuteAsync(() async {
          await Future.delayed(Duration(milliseconds: 10));
          return 'delayed result';
        });

        expect(result, equals('delayed result'));
      });

      test('should wrap exception in AppException with default message', () async {
        expect(
          () => handler.safeExecuteAsync(
            () async => throw Exception('Async error'),
          ),
          throwsA(
            isA<AppException>()
                .having(
                  (e) => e.message,
                  'message',
                  contains('An error occurred'),
                )
                .having(
                  (e) => e.message,
                  'message',
                  contains('Async error'),
                ),
          ),
        );
      });

      test('should wrap exception in AppException with custom error message', () async {
        expect(
          () => handler.safeExecuteAsync(
            () async => throw Exception('Async error'),
            errorMessage: 'Custom async error',
          ),
          throwsA(
            isA<AppException>()
                .having(
                  (e) => e.message,
                  'message',
                  contains('Custom async error'),
                )
                .having(
                  (e) => e.message,
                  'message',
                  contains('Async error'),
                ),
          ),
        );
      });

      test('should preserve original exception if it is an Exception', () async {
        final originalException = Exception('Original async');

        try {
          await handler.safeExecuteAsync(() async => throw originalException);
          fail('Should have thrown AppException');
        } catch (e) {
          expect(e, isA<AppException>());
          expect((e as AppException).originalError, equals(originalException));
        }
      });

      test('should handle non-Exception errors in async', () async {
        expect(
          () => handler.safeExecuteAsync(() async => throw 'Async string error'),
          throwsA(
            isA<AppException>()
                .having(
                  (e) => e.message,
                  'message',
                  contains('Async string error'),
                )
                .having(
                  (e) => e.originalError,
                  'originalError',
                  isNull,
                ),
          ),
        );
      });

      test('should handle errors thrown after delay', () async {
        expect(
          () => handler.safeExecuteAsync(() async {
            await Future.delayed(Duration(milliseconds: 10));
            throw Exception('Delayed error');
          }),
          throwsA(isA<AppException>()),
        );
      });
    });
  });
}

// Test class that implements ErrorHandler mixin
class TestErrorHandler with ErrorHandler {}
