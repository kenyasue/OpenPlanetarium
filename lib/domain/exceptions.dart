/// Base exception shared across the app (maps to the error classification in docs/functional-design.md).
sealed class AppException implements Exception {
  const AppException(this.message);

  /// User-presentable message
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Location unavailable (permission denied or timeout).
///
/// On occurrence, fall back to a manually set location or the default location.
class LocationUnavailableException extends AppException {
  const LocationUnavailableException(super.message);
}

/// Input validation failure.
class ValidationException extends AppException {
  const ValidationException(super.message, {required this.field});

  /// Name of the field that had the error
  final String field;
}

/// Corrupted catalog data (malformed format or checksum mismatch).
///
/// Discard the affected data and continue rendering the sky with the rest.
class CatalogCorruptedException extends AppException {
  const CatalogCorruptedException(super.message);
}

/// Download failure (network or server error).
class DownloadException extends AppException {
  const DownloadException(super.message, {this.retryable = true});

  /// Whether a retry may recover (false for 4xx errors)
  final bool retryable;
}

/// Catalog distribution server not configured (CATALOG_BASE_URL unset).
class DownloadUnavailableException extends AppException {
  const DownloadUnavailableException(super.message);
}
