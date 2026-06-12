import 'dart:typed_data';

import '../models/catalog_download.dart';

/// Access interface for the catalog distribution server (implemented in the data layer).
///
/// Throws [DownloadException] on communication failure, and
/// [DownloadUnavailableException] when the distribution URL is not configured (exceptions.dart).
abstract class DownloadClient {
  Future<CatalogManifest> fetchManifest(String catalogId);

  Future<Uint8List> fetchTile(String catalogId, int tileIndex);
}
