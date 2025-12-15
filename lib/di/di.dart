import 'package:server/handler/handler.dart';
import 'package:server/repository/repository.dart';
import 'package:server/service/service.dart';

/// Dependency Injection container for the application.
///
/// Provides singleton instances of all application services and handlers.
/// Uses lazy initialization to create instances only when first accessed.
class DI {
  /// Singleton instance of the DI container.
  static final DI _instance = DI._();

  /// Factory constructor returns the singleton instance.
  factory DI() => _instance;

  /// Private constructor to prevent external instantiation.
  DI._();

  /// Repository instance (cached after first access).
  late final Repository repository = RepositoryImpl();

  /// Service instance (cached after first access).
  late final Service service = ServiceImpl(repository);

  /// Handler instance (cached after first access).
  late final HandlerImpl handler = HandlerImpl(service);
}
