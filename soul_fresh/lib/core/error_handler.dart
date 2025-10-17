import 'package:dio/dio.dart';
import '../utils/constants.dart';

/// Centralized error handling
class ErrorHandler {
  ErrorHandler._();

  /// Parse error from exception
  static AppError parse(Object error, {StackTrace? stackTrace}) {
    if (error is DioException) {
      return _handleDioException(error);
    } else if (error is AppError) {
      return error;
    } else {
      return AppError(
        message: error.toString(),
        type: ErrorType.unknown,
        originalError: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Handle Dio exceptions
  static AppError _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppError(
          message: 'Connection timeout. Please try again.',
          type: ErrorType.network,
          originalError: error,
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(error);

      case DioExceptionType.cancel:
        return AppError(
          message: 'Request cancelled',
          type: ErrorType.cancelled,
          originalError: error,
        );

      case DioExceptionType.connectionError:
        return AppError(
          message: Constants.errorNetwork,
          type: ErrorType.network,
          originalError: error,
        );

      case DioExceptionType.badCertificate:
        return AppError(
          message: 'Security certificate error',
          type: ErrorType.network,
          originalError: error,
        );

      default:
        return AppError(
          message: Constants.errorUnknown,
          type: ErrorType.unknown,
          originalError: error,
        );
    }
  }

  /// Handle bad response errors
  static AppError _handleBadResponse(DioException error) {
    final response = error.response;
    if (response == null) {
      return AppError(
        message: Constants.errorServer,
        type: ErrorType.server,
        originalError: error,
      );
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    // Extract error message from response
    String message = Constants.errorServer;
    if (data is Map) {
      message = data['detail']?.toString() ??
          data['message']?.toString() ??
          data['error']?.toString() ??
          message;
    } else if (data is String) {
      message = data;
    }

    // Determine error type based on status code
    ErrorType type;
    if (statusCode >= 400 && statusCode < 500) {
      type = ErrorType.validation;
      if (statusCode == 401) {
        type = ErrorType.authentication;
        message = Constants.errorSessionExpired;
      } else if (statusCode == 403) {
        type = ErrorType.authorization;
        message = 'You don\'t have permission to perform this action.';
      } else if (statusCode == 404) {
        type = ErrorType.notFound;
        message = 'Resource not found.';
      } else if (statusCode == 429) {
        type = ErrorType.rateLimit;
        message = 'Too many requests. Please try again later.';
      }
    } else if (statusCode >= 500) {
      type = ErrorType.server;
    } else {
      type = ErrorType.unknown;
    }

    return AppError(
      message: message,
      type: type,
      statusCode: statusCode,
      originalError: error,
    );
  }

  /// Get user-friendly message
  static String getUserMessage(Object error) {
    if (error is AppError) {
      return error.message;
    }
    return parse(error).message;
  }

  /// Check if error is network related
  static bool isNetworkError(Object error) {
    if (error is AppError) {
      return error.type == ErrorType.network;
    }
    return parse(error).type == ErrorType.network;
  }

  /// Check if error requires re-authentication
  static bool requiresReauth(Object error) {
    if (error is AppError) {
      return error.type == ErrorType.authentication;
    }
    return parse(error).type == ErrorType.authentication;
  }
}

/// Error types
enum ErrorType {
  network,
  server,
  validation,
  authentication,
  authorization,
  notFound,
  rateLimit,
  cancelled,
  unknown,
}

/// Custom error class
class AppError implements Exception {
  final String message;
  final ErrorType type;
  final int? statusCode;
  final Object? originalError;
  final StackTrace? stackTrace;

  AppError({
    required this.message,
    required this.type,
    this.statusCode,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => message;

  /// Check if this is a network error
  bool get isNetwork => type == ErrorType.network;

  /// Check if this requires re-authentication
  bool get requiresReauth => type == ErrorType.authentication;

  /// Check if this is a server error
  bool get isServer => type == ErrorType.server;

  /// Check if this is a validation error
  bool get isValidation => type == ErrorType.validation;
}
