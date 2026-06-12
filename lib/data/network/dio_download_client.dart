import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../domain/exceptions.dart';
import '../../domain/models/catalog_download.dart';
import '../../domain/repositories/download_client.dart';

/// Catalog distribution URL (build-time constant. Example:
/// flutter build --dart-define=CATALOG_BASE_URL=https://example.com/catalogs)
const String kCatalogBaseUrl = String.fromEnvironment('CATALOG_BASE_URL');

/// Catalog download client backed by dio (HTTPS only).
class DioDownloadClient implements DownloadClient {
  DioDownloadClient({Dio? dio, String? baseUrl})
    : _dio = dio ?? Dio(),
      _baseUrl = baseUrl ?? kCatalogBaseUrl;

  final Dio _dio;
  final String _baseUrl;

  void _ensureConfigured() {
    if (_baseUrl.isEmpty) {
      throw const DownloadUnavailableException(
        'Catalog distribution server is not configured (CATALOG_BASE_URL is unset)',
      );
    }
    if (!_baseUrl.startsWith('https://')) {
      throw const DownloadUnavailableException(
        'Catalog distribution supports HTTPS only',
      );
    }
  }

  @override
  Future<CatalogManifest> fetchManifest(String catalogId) async {
    _ensureConfigured();
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/$catalogId/manifest.json',
      );
      return CatalogManifest.fromJson(response.data!);
    } on DioException catch (e) {
      throw DownloadException(
        'Failed to fetch manifest: ${e.message}',
        retryable: _isRetryable(e),
      );
    }
  }

  @override
  Future<Uint8List> fetchTile(String catalogId, int tileIndex) async {
    _ensureConfigured();
    try {
      final response = await _dio.get<List<int>>(
        '$_baseUrl/$catalogId/tiles/$tileIndex.bin',
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data!);
    } on DioException catch (e) {
      throw DownloadException(
        'Failed to fetch tile $tileIndex: ${e.message}',
        retryable: _isRetryable(e),
      );
    }
  }

  static bool _isRetryable(DioException e) {
    final status = e.response?.statusCode;
    // 4xx (e.g. 404) is not retryable; anything else (timeout, 5xx) is
    return status == null || status >= 500;
  }
}
