# Store Listing Metadata — Open Planetarium

Single source of truth for store submissions (Google Play / Apple App Store /
Microsoft Store). Values are ready to paste; character limits are noted per
field. Text fields provide **en-US** and **ja-JP**.

- App name: **Open Planetarium**
- Application ID: `agency.catsai.openplanetarium`
- Current version: 0.2.0 (build 2)
- Price: Free, no ads, no in-app purchases
- Repository: https://github.com/kenyasue/OpenPlanetarium

> **TODO before first submission**
> - [ ] Privacy policy URL is required by all three stores. Suggested: publish
>   `docs/privacy-policy.md` via GitHub Pages
>   (e.g. `https://kenyasue.github.io/OpenPlanetarium/privacy-policy`).
> - [ ] Google Play feature graphic (1024×500) is not yet in store-assets/.
> - [ ] Verify screenshot sizes per store (see Graphic Assets at the bottom).

---

## Common Values (all stores)

| Field | Value |
|---|---|
| App name | Open Planetarium |
| Developer name | Ken Yasue |
| Support email | ken@catsai.agency |
| Website / Marketing URL | https://github.com/kenyasue/OpenPlanetarium |
| Support URL | https://github.com/kenyasue/OpenPlanetarium/issues |
| Privacy policy URL | TODO (see above) |
| Category | Education (secondary: Reference) |
| Age rating | All ages (IARC 3+ / Apple 4+ / ESRB Everyone) |
| Contains ads | No |
| In-app purchases | No |
| Account required | No |
| Copyright | © 2026 Ken Yasue. MIT License. Data: HYG v4.1, OpenNGC (CC BY-SA 4.0), Stellarium sky culture, Natural Earth, DSS2 (CDS/Aladin, STScI/NASA) |

### Short description (≤80 chars both stores that use it)

- **en-US** (77): `Beautiful, scientifically accurate planetarium — explore the night sky offline.`
- **ja-JP** (37): `美しく科学的に正確なプラネタリウム。星・惑星・星雲星団をオフラインで観察。`

### Long description (Play ≤4000 / App Store ≤4000 / MS Store ≤10000)

**en-US**

```
Open Planetarium is a beautiful, scientifically accurate virtual planetarium.
The full sky works completely offline — all star, constellation, and deep-sky
data is bundled with the app.

FEATURES

• Real star catalog: 8,920 stars down to magnitude 6.5 (HYG v4.1), with
  scientifically accurate star colors derived from each star's B-V color index
• All 88 constellations: lines, names (English / Japanese / Latin), and
  official IAU boundaries
• Solar system: the Sun, the Moon with phases and lunar age, and all 7 planets,
  computed with Meeus/Standish-compliant algorithms
• Deep-sky objects: the complete Messier catalog (110 objects) plus major
  NGC/IC objects — 717 objects in total, with type icons
• Powerful search: object names, constellations, M/NGC/IC numbers, planets
• Object details: magnitude, coordinates, altitude/azimuth, and
  rise/transit/set times for your location
• Time travel: set any date and time with the calendar dialog, scrub through
  the day with the time slider, or play diurnal motion at 60×/600×/3600×
• Observing location: pick your spot on a zoomable world map with 1,250+
  cities, search by country/city, enter coordinates manually, or use GPS
• Survey imagery: overlay DSS2 sky survey layers (downloaded on demand and
  cached for offline re-display)
• Equipment & field-of-view simulator: register telescopes, cameras, eyepieces
  and Barlows/reducers to preview framing and plan mosaic imaging
• Milky Way rendering and adjustable light-pollution levels

PRIVACY

Your location is used only on your device to compute the sky above you —
it is never sent anywhere. If location permission is denied, you can set the
observing location manually.

Open Planetarium is free, open source (MIT), with no ads and no tracking.
```

**ja-JP**

```
Open Planetarium は、美しさと科学的な正確さを両立した本格プラネタリウムアプリです。
恒星・星座・星雲星団のデータをすべて内蔵しているため、電波の届かない観測地でも
完全オフラインで満天の星空を再現できます。

主な機能

• 実在の星表: HYG v4.1 由来の 8,920 個の恒星（6.5 等まで）を収録。B-V 色指数から
  算出した科学的に正確な星の色を再現
• 全 88 星座: 星座線・星座名（日本語/英語/ラテン語）・IAU 公式の星座境界線
• 太陽系天体: 太陽・月（月相と月齢表示）・7 惑星の位置を Meeus/Standish 準拠の
  アルゴリズムで計算
• 星雲・星団・銀河: メシエ天体全 110 個＋主要な NGC/IC 天体、合計 717 天体を
  種別アイコン付きで表示
• 強力な検索: 天体名（日本語/英語）・星座名・M/NGC/IC 番号・惑星名に対応
• 天体詳細: 等級・座標・高度方位・出没南中時刻を観測地に合わせて表示
• 時間の操作: カレンダーで任意の日時を設定、タイムスライダーで一日を自由に移動、
  日周運動を 60 倍/600 倍/3600 倍で再生
• 観測地の設定: ズーム可能な世界地図と 1,250 以上の主要都市から選択。国・都市の
  検索、緯度経度の手入力、GPS にも対応
• サーベイ画像: DSS2 の実写サーベイを星図に重ねて表示（ダウンロード後は
  オフラインでも再表示可能）
• 機材・視野シミュレーター: 望遠鏡・カメラ・アイピース・バロー/レデューサーを
  登録して視野枠の確認やモザイク撮影の計画が可能
• 天の川の描画、光害レベルの調整

プライバシー

位置情報は端末内でのみ空の計算に使用され、外部に送信されることは一切ありません。
位置情報の利用を許可しない場合も、観測地を手動で設定できます。

Open Planetarium は無料・オープンソース（MIT ライセンス）で、広告・トラッキングは
ありません。
```

---

## Google Play (Play Console)

| Field | Limit | Value |
|---|---|---|
| App name | 30 | Open Planetarium |
| Short description | 80 | → Common: Short description |
| Full description | 4000 | → Common: Long description |
| App category | — | Application → Education |
| Tags | 5 | Astronomy, Education, Stargazing, Science, Reference |
| Email | — | ken@catsai.agency |
| Website | — | https://github.com/kenyasue/OpenPlanetarium |
| Privacy policy | required | TODO |
| Price | — | Free |
| Countries | — | All countries |
| Default language | — | en-US (add ja-JP listing) |

### Content rating questionnaire (IARC)

- Violence / sexuality / profanity / drugs / gambling: **No** to all
- User-generated content or user interaction: **No**
- Shares user location with third parties: **No**
- Digital purchases: **No**
- → Expected rating: **Everyone / 3+**

### Data safety form

| Question | Answer | Notes |
|---|---|---|
| Does the app collect or share user data? | **No** | Location is processed on-device only and never transmitted (docs/product-requirements.md "Security and Privacy") |
| Location permission declared | Yes (`ACCESS_FINE_LOCATION`) | Optional; manual fallback exists |
| Data encrypted in transit | N/A (no user data transmitted) | Survey tile downloads are HTTPS |
| Data deletion request mechanism | N/A | No accounts, no server-side data |

### Release notes (0.2.0) — `<xx-XX>` blocks, ≤500 each

- **en-US**: `New: calendar-based time settings dialog; world map observing-location picker with 1,250+ searchable cities; object names now follow the language setting; Android performance fixes.`
- **ja-JP**: `カレンダー式の時刻設定ダイアログを追加。1,250以上の都市を検索できる世界地図の観測地ピッカーを搭載。天体名が言語設定に追従するようになりました。Androidの性能改善も実施。`

---

## Apple App Store (App Store Connect)

| Field | Limit | Value |
|---|---|---|
| App name | 30 | Open Planetarium |
| Subtitle | 30 | Offline star chart & sky guide |
| Subtitle (ja) | 30 | オフラインで使える本格星図 |
| Promotional text | 170 | See the real night sky anywhere — no connection needed. Stars, planets, Messier objects, telescope FOV simulation, and a world-map location picker. |
| Promotional text (ja) | 170 | 電波の届かない場所でも満天の星空を。恒星・惑星・メシエ天体、望遠鏡の視野シミュレーション、世界地図からの観測地選択に対応。 |
| Description | 4000 | → Common: Long description |
| Keywords (en) | 100 | planetarium,star chart,astronomy,night sky,constellation,telescope,messier,stargazing,stars |
| Keywords (ja) | 100 | プラネタリウム,星図,天体観測,星座,望遠鏡,メシエ,星空,天文,アストロノミー |
| Primary category | — | Education |
| Secondary category | — | Reference |
| Age rating | — | 4+ (no objectionable content) |
| Support URL | — | https://github.com/kenyasue/OpenPlanetarium/issues |
| Marketing URL | — | https://github.com/kenyasue/OpenPlanetarium |
| Privacy policy URL | required | TODO |
| Copyright | — | © 2026 Ken Yasue |
| Price | — | Free (Tier 0) |

### App Privacy (nutrition label)

| Question | Answer |
|---|---|
| Location | **Not collected** (used on-device only, never leaves the device) |
| Tracking | No |
| Data linked to user | None |
| `NSLocationWhenInUseUsageDescription` | "Your location is used only on this device to show the sky above you. It is never sent anywhere." |

### What's New (0.2.0)

→ Google Play の Release notes と同文（en / ja）

---

## Microsoft Store (Partner Center)

| Field | Limit | Value |
|---|---|---|
| App name (reservation) | — | Open Planetarium |
| Description | 10000 | → Common: Long description |
| App features (up to 20 × 200) | — | Offline star catalog (8,920 stars) / All 88 IAU constellations / Sun, Moon & 7 planets / 717 deep-sky objects / DSS2 survey overlays / Telescope FOV simulator / World-map location picker / Diurnal motion playback |
| Search terms | 7 × 45 | planetarium; astronomy; star chart; night sky; constellation; telescope; stargazing |
| Category | — | Education |
| Subcategory | — | (none) |
| Age rating (IARC) | — | 3+ (same questionnaire answers as Google Play) |
| Privacy policy URL | required | TODO |
| Website | — | https://github.com/kenyasue/OpenPlanetarium |
| Support contact | — | ken@catsai.agency |
| Pricing | — | Free |
| Markets | — | All markets |
| System requirements | — | Windows 10 version 1809+ (x64) |

> Note: Microsoft Store submission requires MSIX packaging
> (e.g. `msix` pub package: `dart run msix:create`). Not set up yet — the
> current Windows distribution is the GitHub Releases zip.

---

## Graphic Assets

| Asset | Requirement | Status |
|---|---|---|
| App icon (Play) | 512×512 PNG, ≤1MB | Generate from `assets/icon.png` (1254×1254) — downscale to 512 |
| App icon (App Store) | 1024×1024 PNG, no alpha | Generated in `ios/.../AppIcon.appiconset` ✓ |
| Feature graphic (Play) | 1024×500 PNG/JPG, required | **TODO** (can be cropped from `assets/icon.png` / `splashscreen.png`) |
| Phone screenshots (Play) | ≥2, 16:9 or 9:16, 320–3840px | ✓ `android/phone/01-09.png` (9 × 1080×1920) |
| 7"/10" tablet screenshots (Play) | recommended | TODO (optional; `iOS/tablet` cannot be reused as-is — Play tablet max 3840px is fine, aspect ok, but branding says iPad) |
| iPhone 6.9" screenshots (App Store) | ≥1 | ✓ `iOS/phone/01-09.png` (9 × 1320×2868, iPhone 16 Pro Max size) |
| iPad 13" screenshots (App Store) | required if iPad supported | ✓ `iOS/tablet/01-09.png` (9 × 2064×2752, iPad Pro 13" portrait) |
| MS Store screenshots | ≥1, 1366×768+ recommended | **TODO** — only portrait mobile shots exist; capture desktop (landscape) screenshots from the Windows build |
| Source captures | — | `1-9.png` (720×1612 raw captures used by `build_store_screenshots.py`) |
| Splash/promo | store-optional | `assets/splashscreen.png` (941×1672) |
