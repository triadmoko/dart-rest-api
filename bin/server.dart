import 'dart:io';

import 'package:server/di/di.dart';
import 'package:server/middleware/response_time_middleware.dart';
import 'package:server/router/router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;

Future<void> main() async {
  DI di = DI();
  // See https://pub.dev/documentation/shelf/latest/shelf/Cascade-class.html
  final cascade = Cascade()
      // First, serve files from the 'public' directory
      // If a corresponding file is not found, send requests to a `Router`
      .add(Routes(shelf_router.Router(), di).router.call);

  // Setup middleware pipeline
  // Middleware dijalankan dari atas ke bawah
  final handler = const Pipeline()
      // 1. Response Time Middleware - mengukur waktu pemrosesan
      //    Set enableLogging: true untuk development, false untuk production
      .addMiddleware(responseTimeMiddleware(enableLogging: true))
      // 2. Request logging middleware (built-in Shelf)
      .addMiddleware(logRequests())
      // 3. Handler untuk memproses request
      .addHandler(cascade.handler);

  // See https://pub.dev/documentation/shelf/latest/shelf_io/serve.html
  final server = await shelf_io.serve(
    handler,
    InternetAddress.anyIPv4, // Allows external connections
    8080,
  );

  print('Serving at http://${server.address.host}:${server.port}');
  print('Response Time Middleware: ENABLED');

  // Used for tracking uptime of the demo server.
  _watch.start();
}

final _watch = Stopwatch();
