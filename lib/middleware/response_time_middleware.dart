import 'package:shelf/shelf.dart';

/// Middleware untuk mengukur waktu pemrosesan request dan menambahkan
/// header X-Response-Time ke response.
///
/// Middleware ini berguna untuk:
/// - Monitoring performance aplikasi
/// - Identifikasi endpoint yang lambat
/// - Debugging bottleneck
///
/// Example:
/// ```dart
/// final handler = const Pipeline()
///     .addMiddleware(responseTimeMiddleware(enableLogging: true))
///     .addHandler(myHandler);
/// ```
///
/// Parameters:
/// - [enableLogging]: Jika true, akan print log ke console untuk setiap request.
///                    Default: false
///
/// Response Header:
/// - X-Response-Time: Waktu eksekusi dalam format "12.34ms"
Middleware responseTimeMiddleware({bool enableLogging = false}) {
  return (Handler innerHandler) {
    return (Request request) async {
      // 1. Mulai stopwatch untuk mengukur waktu
      final stopwatch = Stopwatch()..start();

      // 2. Proses request melalui handler berikutnya
      final response = await innerHandler(request);

      // 3. Stop stopwatch dan hitung elapsed time
      stopwatch.stop();

      // Convert microseconds ke milliseconds untuk readability
      final elapsedMs = stopwatch.elapsedMicroseconds / 1000;

      // 4. (Optional) Print log ke console jika logging enabled
      if (enableLogging) {
        print(
          '[Response Time] ${request.method} ${request.url.path} - '
          '${elapsedMs.toStringAsFixed(2)}ms',
        );
      }

      // 5. Tambahkan header X-Response-Time ke response
      // Gunakan response.change() karena Response objects immutable
      return response.change(
        headers: {
          'X-Response-Time': '${elapsedMs.toStringAsFixed(2)}ms',
        },
      );
    };
  };
}
