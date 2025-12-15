import 'dart:convert';

import 'package:server/constants/constants.dart';
import 'package:server/dto/request.dart';
import 'package:server/service/service.dart';
import 'package:server/tools/exception.dart';
import 'package:shelf/shelf.dart';

String _jsonEncode(Object? data) =>
    const JsonEncoder.withIndent(' ').convert(data);
const _jsonHeaders = {'content-type': 'application/json'};

/// HTTP request handlers for todo operations.
///
/// Handles HTTP requests and responses, delegating business logic to the service layer.
class HandlerImpl with ErrorHandler {
  /// Service layer for business logic.
  final Service _service;

  HandlerImpl(this._service);

  /// Logs an error with stack trace.
  void _logError(Object error, StackTrace stackTrace, String operation) {
    print('[ERROR] $operation failed:');
    print('  Error: $error');
    print('  Stack trace:');
    print('    ${stackTrace.toString().replaceAll('\n', '\n    ')}');
  }

  /// Handles POST /todo - creates a new todo.
  Future<Response> create(Request request) async {
    try {
      final String body = await request.readAsString();
      final Json data = jsonDecode(body) as Json;
      final req = RequestTodo.fromJson(data);

      final response = await _service.create(req);
      return Response.ok(
        _jsonEncode({"result": response.toJson()}),
        headers: {..._jsonHeaders},
      );
    } catch (e, stackTrace) {
      _logError(e, stackTrace, 'CREATE todo');
      return Response.internalServerError(
        body: jsonEncode({
          "error": e is AppException ? e.message : 'Internal Server Error',
          "result": null,
        }),
        headers: {..._jsonHeaders},
      );
    }
  }

  /// Handles GET /todo - retrieves all todos.
  Future<Response> getAll(Request request) async {
    try {
      final response = await _service.getAll();
      return Response.ok(
        _jsonEncode({
          "result": response.map((todo) => todo.toJson()).toList(),
        }),
        headers: {..._jsonHeaders},
      );
    } catch (e, stackTrace) {
      _logError(e, stackTrace, 'GET all todos');
      return Response.internalServerError(
        body: jsonEncode({
          "error": e is AppException ? e.message : 'Internal Server Error',
          "result": null,
        }),
        headers: {..._jsonHeaders},
      );
    }
  }

  /// Handles GET /todo/:id - retrieves a todo by ID.
  Future<Response> getById(Request request, String id) async {
    try {
      final todoId = int.parse(id);
      final response = await _service.getById(todoId);

      if (response == null) {
        return Response.notFound(
          jsonEncode({
            "error": "Todo with id $id not found",
            "result": null,
          }),
          headers: {..._jsonHeaders},
        );
      }

      return Response.ok(
        _jsonEncode({"result": response.toJson()}),
        headers: {..._jsonHeaders},
      );
    } on FormatException catch (e, stackTrace) {
      _logError(e, stackTrace, 'GET todo by id (invalid id format)');
      return Response.badRequest(
        body: jsonEncode({
          "error": "Invalid id format",
          "result": null,
        }),
        headers: {..._jsonHeaders},
      );
    } catch (e, stackTrace) {
      _logError(e, stackTrace, 'GET todo by id');
      return Response.internalServerError(
        body: jsonEncode({
          "error": e is AppException ? e.message : 'Internal Server Error',
          "result": null,
        }),
        headers: {..._jsonHeaders},
      );
    }
  }

  /// Handles PUT /todo/:id - updates a todo.
  Future<Response> update(Request request, String id) async {
    try {
      final todoId = int.parse(id);
      final String body = await request.readAsString();
      final Json data = jsonDecode(body) as Json;

      final req = RequestTodo.fromJson(data);
      final response = await _service.update(todoId, req);

      return Response.ok(
        _jsonEncode({"result": response.toJson()}),
        headers: {..._jsonHeaders},
      );
    } on FormatException catch (e, stackTrace) {
      _logError(e, stackTrace, 'UPDATE todo (invalid id format)');
      return Response.badRequest(
        body: jsonEncode({
          "error": "Invalid id format",
          "result": null,
        }),
        headers: {..._jsonHeaders},
      );
    } catch (e, stackTrace) {
      _logError(e, stackTrace, 'UPDATE todo');
      return Response.internalServerError(
        body: jsonEncode({
          "error": e is AppException ? e.message : 'Internal Server Error',
          "result": null,
        }),
        headers: {..._jsonHeaders},
      );
    }
  }

  /// Handles DELETE /todo/:id - deletes a todo.
  Future<Response> delete(Request request, String id) async {
    try {
      final todoId = int.parse(id);
      await _service.delete(todoId);

      return Response.ok(
        _jsonEncode({
          "message": "Todo deleted successfully",
          "result": null,
        }),
        headers: {..._jsonHeaders},
      );
    } on FormatException catch (e, stackTrace) {
      _logError(e, stackTrace, 'DELETE todo (invalid id format)');
      return Response.badRequest(
        body: jsonEncode({
          "error": "Invalid id format",
          "result": null,
        }),
        headers: {..._jsonHeaders},
      );
    } catch (e, stackTrace) {
      _logError(e, stackTrace, 'DELETE todo');
      return Response.internalServerError(
        body: jsonEncode({
          "error": e is AppException ? e.message : 'Internal Server Error',
          "result": null,
        }),
        headers: {..._jsonHeaders},
      );
    }
  }
}
