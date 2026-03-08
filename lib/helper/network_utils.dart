import 'dart:async';

import 'package:flutter/foundation.dart';

/// Runs [fn] with [timeout]. On [TimeoutException] or other error, retries up to
/// [maxRetries] times, waiting [retryDelay] between attempts. Rethrows on final failure.
Future<T> runWithTimeoutAndRetry<T>(
  Future<T> Function() fn, {
  Duration timeout = const Duration(seconds: 10),
  int maxRetries = 2,
  Duration retryDelay = const Duration(seconds: 1),
}) async {
  int attempt = 0;
  while (true) {
    try {
      return await fn().timeout(
        timeout,
        onTimeout: () => throw TimeoutException('Operation timed out after $timeout'),
      );
    } catch (e, st) {
      attempt++;
      debugPrint("[FeedDebug] runWithTimeoutAndRetry: attempt $attempt failed: $e");
      if (attempt > maxRetries) rethrow;
      await Future.delayed(retryDelay);
    }
  }
}
