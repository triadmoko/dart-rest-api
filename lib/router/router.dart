import 'package:server/di/di.dart';
import 'package:shelf_router/shelf_router.dart' as shelf_router;

class Routes {
  final DI _di;
  final shelf_router.Router _router;

  Routes(this._router, this._di) {
    _router.post('/todo', _di.handler.create);
    _router.get('/todo', _di.handler.getAll);
    _router.get('/todo/<id>', _di.handler.getById);
    _router.put('/todo/<id>', _di.handler.update);
    _router.delete('/todo/<id>', _di.handler.delete);
  }
  shelf_router.Router get router => _router;
}
