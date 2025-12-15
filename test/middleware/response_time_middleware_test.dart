import 'package:server/middleware/response_time_middleware.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  group('responseTimeMiddleware', () {
    group('Header X-Response-Time', () {
      test('should add X-Response-Time header to response', () async {
        // Setup: Buat handler sederhana
        final handler = const Pipeline()
            .addMiddleware(responseTimeMiddleware())
            .addHandler(_testHandler);

        // Execute: Kirim request
        final request = Request('GET', Uri.parse('http://localhost/test'));
        final response = await handler(request);

        // Verify: Header harus ada
        expect(response.headers.containsKey('x-response-time'), isTrue);
      });

      test('should have correct format (number + "ms")', () async {
        final handler = const Pipeline()
            .addMiddleware(responseTimeMiddleware())
            .addHandler(_testHandler);

        final request = Request('GET', Uri.parse('http://localhost/test'));
        final response = await handler(request);

        final responseTime = response.headers['x-response-time']!;

        // Verify: Format harus seperti "12.34ms"
        expect(responseTime, matches(RegExp(r'^\d+\.\d{2}ms$')));
      });

      test('should measure time greater than 0ms', () async {
        final handler = const Pipeline()
            .addMiddleware(responseTimeMiddleware())
            .addHandler(_testHandler);

        final request = Request('GET', Uri.parse('http://localhost/test'));
        final response = await handler(request);

        final responseTime = response.headers['x-response-time']!;
        final timeValue = double.parse(responseTime.replaceAll('ms', ''));

        // Verify: Waktu harus > 0
        expect(timeValue, greaterThan(0));
      });
    });

    group('Response Preservation', () {
      test('should not modify response body', () async {
        final handler = const Pipeline()
            .addMiddleware(responseTimeMiddleware())
            .addHandler(_jsonHandler);

        final request = Request('GET', Uri.parse('http://localhost/json'));
        final response = await handler(request);

        final body = await response.readAsString();

        // Verify: Body tetap sama
        expect(body, equals('{"message":"Hello World"}'));
      });

      test('should not modify status code', () async {
        final handler = const Pipeline()
            .addMiddleware(responseTimeMiddleware())
            .addHandler(_notFoundHandler);

        final request = Request('GET', Uri.parse('http://localhost/404'));
        final response = await handler(request);

        // Verify: Status code tetap 404
        expect(response.statusCode, equals(404));
      });

      test('should preserve other headers', () async {
        final handler = const Pipeline()
            .addMiddleware(responseTimeMiddleware())
            .addHandler(_customHeaderHandler);

        final request = Request('GET', Uri.parse('http://localhost/custom'));
        final response = await handler(request);

        // Verify: Header custom tetap ada
        expect(response.headers['x-custom-header'], equals('custom-value'));
        // Dan X-Response-Time juga ada
        expect(response.headers.containsKey('x-response-time'), isTrue);
      });
    });

    group('HTTP Methods Support', () {
      test('should work with GET requests', () async {
        final handler = const Pipeline()
            .addMiddleware(responseTimeMiddleware())
            .addHandler(_testHandler);

        final request = Request('GET', Uri.parse('http://localhost/test'));
        final response = await handler(request);

        expect(response.headers.containsKey('x-response-time'), isTrue);
      });

      test('should work with POST requests', () async {
        final handler = const Pipeline()
            .addMiddleware(responseTimeMiddleware())
            .addHandler(_testHandler);

        final request = Request('POST', Uri.parse('http://localhost/test'));
        final response = await handler(request);

        expect(response.headers.containsKey('x-response-time'), isTrue);
      });

      test('should work with PUT requests', () async {
        final handler = const Pipeline()
            .addMiddleware(responseTimeMiddleware())
            .addHandler(_testHandler);

        final request = Request('PUT', Uri.parse('http://localhost/test'));
        final response = await handler(request);

        expect(response.headers.containsKey('x-response-time'), isTrue);
      });

      test('should work with DELETE requests', () async {
        final handler = const Pipeline()
            .addMiddleware(responseTimeMiddleware())
            .addHandler(_testHandler);

        final request = Request('DELETE', Uri.parse('http://localhost/test'));
        final response = await handler(request);

        expect(response.headers.containsKey('x-response-time'), isTrue);
      });
    });

    group('Status Codes Support', () {
      test('should work with 200 OK', () async {
        final handler = const Pipeline()
            .addMiddleware(responseTimeMiddleware())
            .addHandler(_testHandler);

        final request = Request('GET', Uri.parse('http://localhost/test'));
        final response = await handler(request);

        expect(response.statusCode, equals(200));
        expect(response.headers.containsKey('x-response-time'), isTrue);
      });

      test('should work with 404 Not Found', () async {
        final handler = const Pipeline()
            .addMiddleware(responseTimeMiddleware())
            .addHandler(_notFoundHandler);

        final request = Request('GET', Uri.parse('http://localhost/404'));
        final response = await handler(request);

        expect(response.statusCode, equals(404));
        expect(response.headers.containsKey('x-response-time'), isTrue);
      });

      test('should work with 500 Internal Server Error', () async {
        final handler = const Pipeline()
            .addMiddleware(responseTimeMiddleware())
            .addHandler(_errorHandler);

        final request = Request('GET', Uri.parse('http://localhost/error'));
        final response = await handler(request);

        expect(response.statusCode, equals(500));
        expect(response.headers.containsKey('x-response-time'), isTrue);
      });
    });

    group('Delayed Responses', () {
      test('should accurately measure delayed responses', () async {
        final handler = const Pipeline()
            .addMiddleware(responseTimeMiddleware())
            .addHandler(_delayedHandler);

        final request = Request('GET', Uri.parse('http://localhost/slow'));
        final response = await handler(request);

        final responseTime = response.headers['x-response-time']!;
        final timeValue = double.parse(responseTime.replaceAll('ms', ''));

        // Verify: Waktu harus >= 50ms (handler delay 50ms)
        // Gunakan threshold sedikit lebih rendah untuk menghindari flaky test
        expect(timeValue, greaterThanOrEqualTo(45));
      });
    });

    group('Logging', () {
      test('should not log when enableLogging is false (default)', () async {
        // Note: Sulit untuk test console output secara langsung
        // Test ini hanya memastikan middleware tetap berfungsi
        final handler = const Pipeline()
            .addMiddleware(responseTimeMiddleware())
            .addHandler(_testHandler);

        final request = Request('GET', Uri.parse('http://localhost/test'));
        final response = await handler(request);

        expect(response.headers.containsKey('x-response-time'), isTrue);
      });

      test('should not crash when enableLogging is true', () async {
        // Test bahwa logging tidak menyebabkan error
        final handler = const Pipeline()
            .addMiddleware(responseTimeMiddleware(enableLogging: true))
            .addHandler(_testHandler);

        final request = Request('GET', Uri.parse('http://localhost/test'));
        final response = await handler(request);

        expect(response.headers.containsKey('x-response-time'), isTrue);
      });
    });

    group('Edge Cases', () {
      test('should handle concurrent requests independently', () async {
        final handler = const Pipeline()
            .addMiddleware(responseTimeMiddleware())
            .addHandler(_testHandler);

        // Execute: Kirim 3 requests concurrent
        final request1 = handler(Request('GET', Uri.parse('http://localhost/test1')));
        final request2 = handler(Request('GET', Uri.parse('http://localhost/test2')));
        final request3 = handler(Request('GET', Uri.parse('http://localhost/test3')));

        final responses = await Future.wait([
          Future.value(request1),
          Future.value(request2),
          Future.value(request3),
        ]);

        // Verify: Semua response harus punya header
        for (final response in responses) {
          expect(response.headers.containsKey('x-response-time'), isTrue);
        }
      });

      test('should work with empty response body', () async {
        final handler = const Pipeline()
            .addMiddleware(responseTimeMiddleware())
            .addHandler(_emptyHandler);

        final request = Request('GET', Uri.parse('http://localhost/empty'));
        final response = await handler(request);

        expect(response.headers.containsKey('x-response-time'), isTrue);
        final body = await response.readAsString();
        expect(body, isEmpty);
      });
    });
  });
}

// ==================== Test Handlers ====================

/// Handler sederhana yang return 200 OK
Response _testHandler(Request request) {
  return Response.ok('Test response');
}

/// Handler yang return JSON
Response _jsonHandler(Request request) {
  return Response.ok(
    '{"message":"Hello World"}',
    headers: {'content-type': 'application/json'},
  );
}

/// Handler yang return 404
Response _notFoundHandler(Request request) {
  return Response.notFound('Not Found');
}

/// Handler yang return 500
Response _errorHandler(Request request) {
  return Response.internalServerError(body: 'Internal Server Error');
}

/// Handler dengan custom header
Response _customHeaderHandler(Request request) {
  return Response.ok(
    'Custom',
    headers: {'x-custom-header': 'custom-value'},
  );
}

/// Handler dengan delay 50ms
Future<Response> _delayedHandler(Request request) async {
  await Future.delayed(const Duration(milliseconds: 50));
  return Response.ok('Delayed response');
}

/// Handler dengan empty body
Response _emptyHandler(Request request) {
  return Response.ok('');
}
