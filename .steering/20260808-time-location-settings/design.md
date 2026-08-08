# Design Document

## Architecture Overview

既存の 4 層アーキテクチャ（presentation → application → domain ← data）に従う。

```
presentation
  ├ time_settings_dialog.dart        … カレンダー＋時分ドロップダウン（新規）
  ├ location_picker.dart             … 国/都市セレクト＋世界地図＋手入力（LocationSection 刷新）
  └ painters/world_map_painter.dart  … 陸地ポリゴン・都市点・マーカー描画（新規）
application
  └ location/world_cities_provider.dart … 都市カタログの FutureProvider（新規）
domain
  └ models/world_city.dart           … WorldCity モデル＋最寄り都市検索（新規）
data
  └ catalog/world_map_loader.dart    … アセット JSON ロード（新規）
assets/map/
  ├ world_land.json                  … 陸地ポリゴン（Natural Earth 110m land 由来）
  └ world_cities.json                … 都市（Natural Earth 50m populated places 由来）
tool/catalog_converter/
  └ convert_worldmap.dart            … cache/ の GeoJSON → 上記アセット変換（新規）
```

## Component Design

### 1. TimeSettingsDialog（presentation/screens/sky/widgets/time_settings_dialog.dart）

**Responsibilities**:
- `CalendarDatePicker` を埋め込み表示し、日付選択で `TimeController.setTime`（時刻部分は維持）
- 時・分の `DropdownButton<int>`（0–23 / 0–59）で即時反映
- 「Now」ボタンで `resetToNow`。いずれの操作でも `TimePlaybackController.stop()`
- `showTimeSettingsDialog(context)` を公開し、control_bar の時刻テキスト（InkWell 化）と edit_calendar アイコンの両方から呼ぶ

**Implementation notes**:
- 旧 `_TimeSettingsContent` は削除して置き換え
- 状態は timeControllerProvider を watch（ダイアログ内ローカル状態を持たない）
- CalendarDatePicker は onDateChanged のみで反映（key の張り替えはしない）

### 2. WorldCity / nearestCity（domain/models/world_city.dart）

**Responsibilities**:
- `WorldCity { name, country, latitudeDeg, longitudeDeg, isCapital }`（イミュータブル）
- `WorldCity.toGeoLocation()` で既存 `GeoLocation` に変換
- `nearestCity(List<WorldCity>, lat, lon)` … 球面距離（haversine）で最寄り都市と距離 km を返す純関数

**Implementation notes**:
- domain 層なので I/O・Flutter 依存禁止（純 Dart）
- 距離計算の定数（地球半径 6371 km）は出典コメントを付す

### 3. WorldMapLoader（data/catalog/world_map_loader.dart）

**Responsibilities**:
- `rootBundle` から `assets/map/world_cities.json` / `assets/map/world_land.json` をロードしてパース
- 都市: `List<WorldCity>`、陸地: ポリゴンリング `List<List<(lon,lat)>>`

**Implementation notes**:
- ダイアログ初回表示時にロード（数百 KB、compute 不要）
- JSON 形式: cities = `[[name, country, lat, lon, capital(0/1)], ...]`（配列形式でサイズ削減）、land = `[[[lon,lat],...], ...]`

### 4. worldCitiesProvider（application/location/world_cities_provider.dart）

**Responsibilities**:
- `FutureProvider<WorldCityCatalog>`（cities・国リスト（ソート済み）・国→都市 map を保持）
- 陸地ポリゴンも同様に `FutureProvider` で公開

### 5. LocationPicker（presentation/screens/settings/widgets/location_section.dart 刷新）

**Responsibilities**:
- 国 `DropdownMenu`（フィルタ入力可）＋都市 `DropdownMenu`（国選択でエントリをフィルタ）
- 世界地図（`InteractiveViewer` + `CustomPaint`）: タップで緯度経度設定、ズーム 1–8 倍
- タップ時: `nearestCity` が 150 km 以内なら国/都市セレクトを同期、それ以外はクリア
- 既存の緯度経度手入力・GPS チップ・現在地表示は維持
- 都市選択時は `LocationController.setManualLocation(city.toGeoLocation())`

**Implementation notes**:
- 地図座標変換は正距円筒図法: `x = (lon+180)/360*w`, `y = (90-lat)/180*h`（painter と共有のヘルパーに切り出してテスト）
- InteractiveViewer の `transformationController` の逆行列でタップ位置→lon/lat
- ダイアログ幅: control_bar の `_showSettingDialog` に width 引数を追加（Location のみ 640）
- 都市点は全描画で実装し、性能問題があればズーム率で間引く

### 6. convert_worldmap.dart（tool/catalog_converter/convert_worldmap.dart）

**Responsibilities**:
- `cache/ne_110m_land.geojson` と `cache/ne_50m_populated_places_simple.geojson` を読み、精度を落として（小数 2–3 桁）`assets/map/*.json` を生成
- 既存 convert 系スクリプトの体裁（usage コメント、cache/ 入力）に合わせる

## Data Flow

### 地図クリックで観測地を設定
```
1. GestureDetector が localPosition を取得
2. TransformationController の逆行列でシーン座標へ変換 → lon/lat 算出
3. LocationController.setManualLocation(GeoLocation(lat, lon, name: 近傍都市名 or 'Map point'))
4. nearestCity() が 150 km 以内なら国/都市セレクトの選択状態を更新
5. locationControllerProvider の変更で SkyView・ステータス表示が再計算
```

### 国→都市フィルタリング
```
1. 国 DropdownMenu 選択 → setState で selectedCountry 更新
2. 都市 DropdownMenu の entries を catalog.citiesOf(country) で再構築
3. 都市選択 → setManualLocation → マーカー再描画
```

## Error Handling Strategy

- アセットロード失敗: FutureProvider が AsyncError となり地図領域にエラーテキスト表示。セレクト・手入力・GPS は動作継続（「空表示を最後まで守る」原則）
- 緯度経度手入力のバリデーションは既存実装を踏襲（範囲外はインラインエラー）

## Test Strategy

### Unit Tests
- `world_city_test.dart`: haversine 距離・nearestCity（境界: 日付変更線越え）
- `world_map_projection_test.dart`: lon/lat ↔ 地図座標の相互変換
- `world_map_loader_test.dart`: JSON パース（都市・陸地、capital フラグ）

### Widget Tests
- `time_settings_dialog_test.dart`: 日付選択で年月日のみ変わり時刻維持、時分ドロップダウンで反映、再生停止
- `location_picker_test.dart`: 国選択で都市がフィルタされる、都市選択で locationController に反映

## Dependencies

新規パッケージなし（Flutter 標準 + 既存依存のみで実装）。

## Directory Structure

```
assets/map/world_land.json                                        (新規)
assets/map/world_cities.json                                      (新規)
lib/domain/models/world_city.dart                                 (新規)
lib/data/catalog/world_map_loader.dart                            (新規)
lib/application/location/world_cities_provider.dart               (新規)
lib/presentation/painters/world_map_painter.dart                  (新規)
lib/presentation/screens/sky/widgets/time_settings_dialog.dart    (新規)
lib/presentation/screens/sky/widgets/control_bar.dart             (変更)
lib/presentation/screens/settings/widgets/location_section.dart   (刷新)
tool/catalog_converter/convert_worldmap.dart                      (新規)
pubspec.yaml                                                      (assets/map/ 追加)
```

## Implementation Order

1. データ変換ツール＋アセット生成（Natural Earth データ取得 → JSON 生成）
2. domain（WorldCity・投影ヘルパー）＋テスト
3. data（WorldMapLoader）＋ application（provider）＋テスト
4. TimeSettingsDialog ＋ control_bar 接続＋テスト
5. LocationPicker（painter・地図・セレクト）＋テスト
6. 品質チェック（format / analyze / test / Windows debug ビルド）

## Security Considerations

- 実行時のネットワークアクセスなし（アセット同梱）。データ取得はビルド時ツールのみ

## Performance Considerations

- 都市約 1,200 点・陸地ポリゴン（110m 解像度、数千頂点）は CustomPainter 一括描画で問題ない規模
- 地図はダイアログ表示中のみ描画

## Future Extensibility

- 都市データを 10m 解像度に差し替え可能な JSON スキーマ（配列形式）
- タイムゾーン情報を WorldCity に追加すれば都市選択時の時刻表示切替に発展可能
