import 'dart:io';

import 'package:server/middleware/response_time_middleware.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

/// Example server yang mendemonstrasikan penggunaan Response Time Middleware
///
/// Server ini memiliki beberapa endpoint dengan karakteristik berbeda:
/// - /fast - Response cepat tanpa delay
/// - /medium - Response dengan delay 50ms
/// - /slow - Response dengan delay 100ms
/// - /very-slow - Response dengan delay 500ms
/// - /todos - Simulasi query database
///
/// Cara menjalankan:
/// ```bash
/// dart run example/response_time_example.dart
/// ```
///
/// Test dengan curl:
/// ```bash
/// curl -i http://localhost:8081/fast
/// curl -i http://localhost:8081/slow
/// ```
///
/// Perhatikan header X-Response-Time di response!
Future<void> main() async {
  // Setup router dengan berbagai endpoint
  final router = Router();

  // Endpoint: Fast response (~1ms)
  router.get('/fast', (Request request) {
    return Response.ok(
      '{"message":"Fast response!","delay":"0ms"}',
      headers: {'content-type': 'application/json'},
    );
  });

  // Endpoint: Medium response (50ms delay)
  router.get('/medium', (Request request) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return Response.ok(
      '{"message":"Medium response","delay":"50ms"}',
      headers: {'content-type': 'application/json'},
    );
  });

  // Endpoint: Slow response (100ms delay)
  router.get('/slow', (Request request) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return Response.ok(
      '{"message":"Slow response","delay":"100ms"}',
      headers: {'content-type': 'application/json'},
    );
  });

  // Endpoint: Very slow response (500ms delay)
  router.get('/very-slow', (Request request) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Response.ok(
      '{"message":"Very slow response","delay":"500ms"}',
      headers: {'content-type': 'application/json'},
    );
  });

  // Endpoint: Simulasi database query
  router.get('/todos', (Request request) async {
    // Simulasi query delay
    await Future.delayed(const Duration(milliseconds: 25));

    return Response.ok(
      '{"todos":[{"id":1,"title":"Learn Dart"},{"id":2,"title":"Build REST API"}],"count":2}',
      headers: {'content-type': 'application/json'},
    );
  });

  // Endpoint: Root dengan informasi
  router.get('/', (Request request) {
    return Response.ok('''
<!DOCTYPE html>
<html>
<head>
  <title>Response Time Middleware Example</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 40px; }
    h1 { color: #333; }
    .endpoint { background: #f4f4f4; padding: 10px; margin: 10px 0; border-radius: 5px; }
    code { background: #e0e0e0; padding: 2px 5px; border-radius: 3px; }
  </style>
</head>
<body>
  <h1>Response Time Middleware Example</h1>
  <p>Semua endpoint di server ini menggunakan Response Time Middleware.</p>
  <p>Perhatikan header <code>X-Response-Time</code> di setiap response!</p>

  <h2>Available Endpoints:</h2>
  <div class="endpoint">
    <strong>GET /fast</strong> - Fast response (~1ms)
  </div>
  <div class="endpoint">
    <strong>GET /medium</strong> - Medium response (~50ms delay)
  </div>
  <div class="endpoint">
    <strong>GET /slow</strong> - Slow response (~100ms delay)
  </div>
  <div class="endpoint">
    <strong>GET /very-slow</strong> - Very slow response (~500ms delay)
  </div>
  <div class="endpoint">
    <strong>GET /todos</strong> - Simulated database query (~25ms)
  </div>

  <h2>Test dengan curl:</h2>
  <pre>
curl -i http://localhost:8081/fast
curl -i http://localhost:8081/slow
  </pre>

  <h2>Atau buka di browser:</h2>
  <ul>
    <li><a href="/fast">/fast</a></li>
    <li><a href="/medium">/medium</a></li>
    <li><a href="/slow">/slow</a></li>
    <li><a href="/very-slow">/very-slow</a></li>
    <li><a href="/todos">/todos</a></li>
  </ul>
</body>
</html>
''', headers: {'content-type': 'text/html'});
  });

  // Setup middleware pipeline
  // Response Time Middleware akan mengukur waktu setiap request
  final handler = const Pipeline()
      // 1. Response Time Middleware (dengan logging enabled)
      .addMiddleware(responseTimeMiddleware(enableLogging: true))
      // 2. Built-in request logging
      .addMiddleware(logRequests())
      // 3. Router handler
      .addHandler(router.call);

  // Start server di port 8081
  final server = await shelf_io.serve(
    handler,
    InternetAddress.anyIPv4,
    8081,
  );

  print('');
  print('🚀 Server running at http://${server.address.host}:${server.port}');
  print('');
  print('📊 Response Time Middleware is ENABLED with logging');
  print('');
  print('Try these endpoints:');
  print('  GET http://localhost:8081/');
  print('  GET http://localhost:8081/fast');
  print('  GET http://localhost:8081/medium');
  print('  GET http://localhost:8081/slow');
  print('  GET http://localhost:8081/very-slow');
  print('  GET http://localhost:8081/todos');
  print('');
  print('Press Ctrl+C to stop the server');
  print('');
}
