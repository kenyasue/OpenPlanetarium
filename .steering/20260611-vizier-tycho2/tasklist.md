# Task List

## Phase 1: Foundation

- [x] SpatialIndex.tileBounds (the tile's RA/Dec rectangle) + tests
- [x] DownloadController: skip verification on empty sha256 string + tests

## Phase 2: VizieR Client

- [x] New VizieRDownloadClient (local manifest generation, ADQL construction, CSV parsing, magnitude conversion, encoding)
- [x] Switch the downloadClientProvider default (CATALOG_BASE_URL unset → VizieR)
- [x] Update the catalog description text (noting it is fetched from CDS VizieR)
- [x] Unit tests (ADQL, CSV parsing, ID computation, filtering, codec round-trip)

## Phase 3: Verification

- [x] tool/check.ps1 fully passing (200 tests)
- [x] Connection verification against the real VizieR (TAP query format, column layout, 6,335 entries
      in the densest tile, E2E check fetching 1 tile of 2,080 stars with the real client; temporary tests deleted)
- [x] Post-implementation retrospective
- [x] Merge to main and push

---

## Post-implementation Retrospective

### Implementation Completion Date
2026-06-11

### Differences Between Plan and Actual

- As planned. Because pre-verification against the real VizieR (column names, CSV format,
  entry counts in dense regions) was done before implementation, there was no rework.

### Lessons Learned

- The root cause of "no catalog distribution server configured" was that the design assumed a
  self-hosted server with no public default. For astronomical catalogs, the CDS VizieR TAP
  service is official and usable without authentication, and ADQL RA/Dec rectangle queries
  map naturally onto the app's tile partitioning.
- By keeping the DownloadClient abstraction and converting the external format (CSV) to the
  internal format (TileBinaryCodec) on the client side, a new distribution source can be added
  without changing any of the existing pipeline for verification, resume, cancel, and DB registration.
  Since this source has no checksums, the "empty sha256 = skip verification" convention was introduced.
- Tycho-2 ID design: TYC1×200000+TYC2×4+TYC3 fits in int32 and does not collide with
  the bundled BSC IDs.

### Improvement Suggestions for Next Time

- Downloading all 184 tiles takes 184 TAP queries (several minutes). In the future, consider
  queries that batch multiple tiles or fetching raw data from the VizieR FTP.
- Deeper catalogs such as Gaia DR3 can be added with the same TAP approach (ESA Gaia TAP).
