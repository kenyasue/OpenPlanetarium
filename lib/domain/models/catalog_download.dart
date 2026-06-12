/// Definition of an additional catalog (app-managed whitelist).
class CatalogDescriptor {
  const CatalogDescriptor({
    required this.id,
    required this.name,
    required this.description,
  });

  final String id;
  final String name;
  final String description;
}

/// Catalog distribution manifest (`<base>/<catalogId>/manifest.json`).
class CatalogManifest {
  const CatalogManifest({
    required this.catalogId,
    required this.version,
    required this.tiles,
    required this.totalBytes,
  });

  factory CatalogManifest.fromJson(Map<String, dynamic> json) {
    return CatalogManifest(
      catalogId: json['catalogId'] as String,
      version: json['version'] as int,
      tiles: [
        for (final tile in json['tiles'] as List<dynamic>)
          ManifestTile.fromJson(tile as Map<String, dynamic>),
      ],
      totalBytes: json['totalBytes'] as int,
    );
  }

  final String catalogId;
  final int version;
  final List<ManifestTile> tiles;
  final int totalBytes;
}

/// A single tile in the manifest (verified for corruption/tampering via SHA-256).
class ManifestTile {
  const ManifestTile({
    required this.index,
    required this.bytes,
    required this.sha256,
  });

  factory ManifestTile.fromJson(Map<String, dynamic> json) {
    return ManifestTile(
      index: json['index'] as int,
      bytes: json['bytes'] as int,
      sha256: json['sha256'] as String,
    );
  }

  final int index;
  final int bytes;
  final String sha256;
}

/// Catalog download state (maps to the state transitions in docs/glossary.md).
enum DownloadStatus { notDownloaded, downloading, failed, downloaded }

class CatalogDownloadState {
  const CatalogDownloadState({
    this.status = DownloadStatus.notDownloaded,
    this.completedTiles = 0,
    this.totalTiles = 0,
    this.error,
  });

  final DownloadStatus status;
  final int completedTiles;
  final int totalTiles;
  final String? error;

  double get progress => totalTiles == 0 ? 0 : completedTiles / totalTiles;
}

/// Download mode (F4)
enum DownloadMode { auto, wifiOnly, manual }
