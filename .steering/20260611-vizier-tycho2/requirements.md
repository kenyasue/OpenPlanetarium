# Requirements: Download Tycho-2 Directly from CDS VizieR (Configure a Default Distribution Source)

Date: 2026-06-11

## User Request (summary of original wording)

Attempting to download Tycho-2 results in "no catalog distribution server is configured".
Please set the most mainstream URL as the default.

## Background

- The current implementation assumes a self-hosted distribution server (`CATALOG_BASE_URL` + manifest.json + .bin tiles),
  and since no public server exists, it does not work by default.
- The most mainstream official distribution source for Tycho-2 is CDS VizieR (catalog number I/259).
  Partial retrieval is possible via ADQL queries against the TAP service (tapvizier.cds.unistra.fr).

## Acceptance Criteria

- [ ] Downloading Tycho-2 succeeds even with `CATALOG_BASE_URL` unset (default)
- [ ] Existing download management — per-tile fetching, resume, cancel, etc. — keeps working as is
- [ ] To avoid overlap with the bundled BSC (down to mag 6.5), only stars fainter than mag 6.5 up to mag 10.0 are imported
- [ ] When `CATALOG_BASE_URL` is set, the self-hosted server can be used as before
- [ ] All existing tests pass + new tests added
