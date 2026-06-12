# Design: Direct VizieR Download of Tycho-2

## Approach

Keep the `DownloadClient` interface as is, add a new `VizieRDownloadClient` that fetches
Tycho-2 per tile from the CDS VizieR TAP service, and make it the default when
`CATALOG_BASE_URL` is unset.

## VizieRDownloadClient (lib/data/network/vizier_download_client.dart)

- TAP endpoint: `https://tapvizier.cds.unistra.fr/TAPVizieR/tap/sync`
  (GET, REQUEST=doQuery, LANG=ADQL, FORMAT=csv)
- `fetchManifest('tycho2_m10')`: generated locally without server access.
  tiles = all 184 tiles of the SpatialIndex, `sha256: ''` (no checksum verification because of
  client-side conversion; an empty SHA is adopted as the convention for "skip verification")
- `fetchTile`: ADQL query over the tile's RA/Dec rectangle
  `SELECT TYC1,TYC2,TYC3,RAmdeg,DEmdeg,BTmag,VTmag FROM "I/259/tyc2" WHERE ...`
  → parse the CSV and convert to Johnson V magnitude and B-V
  (V = VT − 0.090×(BT−VT), B−V = 0.850×(BT−VT); if BT is missing, V=VT and B-V=null)
  → keep only stars fainter than mag 6.5 and at most mag 10.0 (avoiding overlap with the bundled BSC)
  → binarize with `TileBinaryCodec.encode` and return (reusing the existing import path)
- Star ID: `TYC1×200000 + TYC2×4 + TYC3` (fits in int32, no collisions, does not overlap bundled BSC IDs)
- Tile membership is re-determined with `SpatialIndex.tileIndexOf` (boundary consistency)

## SpatialIndex Extension

- `tileBounds(int tileIndex)`: returns the tile's RA/Dec rectangle (for ADQL query construction)

## DownloadController Changes

- `_fetchTileVerified`: skip verification when `tile.sha256` is an empty string
  (resume detection still works with the existing logic since empty == empty matches)
- `downloadClientProvider`: VizieRDownloadClient when `kCatalogBaseUrl` is empty,
  the conventional DioDownloadClient when it is set

## Tests

- SpatialIndex.tileBounds: contains the center, the corners' tileIndexOf matches, full-sky coverage
- VizieRDownloadClient: unit tests for ADQL construction and CSV parsing
  (missing values / filtering / ID computation) without network access; local manifest generation
- DownloadController: verification skip and resume work with a manifest whose sha256 is empty
