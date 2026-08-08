# Task List

## 🚨 Principle of Full Task Completion

**Continue working until ALL tasks in this file are complete**

### Required Rules
- **Mark every task as `[x]`**
- "Planned as a separate task due to time constraints" is forbidden
- "Deferred because the implementation is too complex" is forbidden
- Do not finish work while leaving incomplete tasks (`[ ]`) behind

---

## Phase 1: 地図・都市データの整備

- [x] Natural Earth データを cache/ に取得（ne_110m_land / ne_50m_populated_places_simple の GeoJSON）
- [x] tool/catalog_converter/convert_worldmap.dart を作成（GeoJSON → assets/map/*.json 変換）
- [x] assets/map/world_land.json / world_cities.json を生成（都市 1,251 件・首都 200 件、計 122KB）
- [x] pubspec.yaml に assets/map/ を追加

## Phase 2: domain 層

- [x] lib/domain/models/world_city.dart を作成（WorldCity、toGeoLocation、haversine 距離、nearestCity）
- [x] lib/domain/models/world_map_projection.dart に正距円筒図法ヘルパー（lon/lat ↔ 正規化座標）を作成
- [x] test/domain/models/world_city_test.dart（距離・最寄り都市・日付変更線境界）
- [x] test/domain/models/world_map_projection_test.dart（相互変換）

## Phase 3: data / application 層

- [x] lib/data/catalog/world_map_loader.dart を作成（アセット JSON → WorldCity / 陸地ポリゴン）
- [x] lib/application/location/world_cities_provider.dart を作成（都市カタログ・陸地の FutureProvider）
- [x] test/data/catalog/world_map_loader_test.dart（パース検証＋実アセット検証）

## Phase 4: 時間設定ダイアログ

- [x] lib/presentation/screens/sky/widgets/time_settings_dialog.dart を作成（CalendarDatePicker 埋め込み＋時分ドロップダウン＋Now）
- [x] control_bar.dart: 時刻テキストを InkWell 化して新ダイアログを開く、edit_calendar アイコンも新ダイアログに差し替え、旧 _TimeSettingsContent を削除
- [x] test/presentation/screens/time_settings_dialog_test.dart（日付変更で時刻維持・時分反映・再生停止）＋control_bar_test.dart を新 UI に更新

## Phase 5: 観測地ピッカー（世界地図＋セレクト）

- [x] lib/presentation/painters/world_map_painter.dart を作成（陸地・都市点・首都区別・現在地マーカー）
- [x] location_section.dart を刷新: 国/都市 DropdownMenu（国→都市フィルタ連動）
- [x] location_section.dart: InteractiveViewer 地図（ズーム・パン、タップで緯度経度設定、セレクト連動）
- [x] location_section.dart: 既存の緯度経度手入力・GPS・現在地表示を維持（都市プリセットチップは都市セレクトに置換）
- [x] control_bar.dart: _showSettingDialog に幅指定を追加し Location ダイアログを 640px に拡大
- [x] test/presentation/screens/location_picker_test.dart（国→都市フィルタ・都市選択・地図タップ・都市スナップ）

## Phase 6: Quality Checks and Fixes

- [x] dart format --set-exit-if-changed lib test tool がパス（0 changed）
- [x] flutter analyze がエラー・警告ゼロ（No issues found）
- [x] flutter test が全件パス（243 件）
- [x] flutter build windows --debug が成功
- [x] npm test / npm run lint / npm run typecheck（ドキュメントツーリング側）がパス

## Phase 6.5: implementation-validator 指摘対応（実装中に追加）

- [x] [Major] LandRing を data 層から lib/domain/models/land_ring.dart へ移動（presentation→data の依存違反解消）
- [x] [Major] lib/domain/repositories/world_map_repository.dart を新設し、worldMapLoaderProvider を Provider&lt;WorldMapRepository&gt; に変更（インターフェース DI パターンへ準拠）
- [x] [Major] WorldMapLoader のパース失敗を CatalogCorruptedException に変換（AssetDsoRepository と同一パターン）
- [x] [Minor] ダイアログ定型文を lib/presentation/widgets/app_dialog.dart に共通化（control_bar と time_settings_dialog の重複解消）
- [x] [Minor] GeoPoint を削除し GeoLocation を再利用（等価性が同一のため重複型だった）
- [x] [Minor] test/application/location/world_cities_provider_test.dart を追加（WorldCityCatalog 単体）
- [x] [Minor] アセット破損時のエラー表示＋手入力継続のウィジェットテストを追加
- [x] [Minor] CalendarDatePicker を観測日付で key 付けし、Now ボタン等の外部日付ジャンプに同期
- [x] 再検証: format 0 changed / analyze 0 issues / 248 テストパス / Windows debug ビルド成功

## Phase 7: Documentation Updates

- [x] README.md の機能一覧を更新（観測地の世界地図選択・時間設定ダイアログ・Natural Earth 出典）
- [x] docs への影響を確認: repository-structure.md に assets/map/ を追記（functional-design.md はアルゴリズム・機能要件レベルの変更なしのため更新不要）
- [x] Post-implementation retrospective (recorded at the bottom of this file)

## Phase 8: フォローアップ（ユーザー指示 2026-08-08）

- [x] 都市選択・地図クリック（都市なし地点含む）・GPS・起動時復元のすべてで緯度経度入力欄へ自動反映（ref.listen で locationControllerProvider に追従）
- [x] 下部コントロールバーのステータスから観測地表示（都市名）を削除（_locationLabelOf ごと削除）
- [x] セクション内の「Current: 名前 (緯度, 経度)」行を削除（入力欄が常に現在値を表示するため冗長）
- [x] 永続化の確認: 全設定経路が LocationController.setManualLocation 経由で settings.manualLocation に保存され、次回起動時に最優先で復元される（既存実装、テストで検証）
- [x] テスト追加: 都市選択/地図タップでの欄自動入力、保存済み観測地の起動時復元（計 249 テストパス）

## Phase 9: Android ANR 対応（ユーザー報告 2026-08-08）

- [x] 原因特定: DropdownMenu が全 1,251 都市エントリのウィジェットを一括構築し UI スレッドをブロック（Android で ANR）
- [x] lib/presentation/widgets/search_picker.dart を新設（検索 TextField ＋ ListView.builder の遅延構築ピッカー、PickerField フィールド）
- [x] location_section.dart の国/都市 DropdownMenu を PickerField ＋ showSearchPickerDialog に置換
- [x] 地図描画最適化: 陸地 Path を正規化座標で一度だけ構築しキャッシュ（buildLandPath）、都市点を drawRawPoints 2 コールに集約（旧: 約 1,250 回の drawCircle）
- [x] ピンチズーム中の毎フレーム setState を廃止し、onInteractionEnd でのみ点サイズを再調整
- [x] テスト更新＋検索フィルタのテスト追加（計 250 テストパス、analyze 0 issues）

## Phase 10: 天体名の言語対応（ユーザー報告 2026-08-09）

- [x] 原因: DeepSkyObject.displayName / MinorBody.displayName / SolarBodyObject.displayName が言語設定を無視して nameJa 優先固定
- [x] domain: displayNameIn(NameLanguage) へ置換（DSO・小天体・SkyObject）、SolarBodyId.nameIn を追加。英語/ラテン語では日本語名を使わず、無ければ言語中立なカタログ名（M31 等）にフォールバック
- [x] presentation: DsoRenderer / MinorBodyRenderer に language を追加（ラベルキャッシュは言語切替で破棄、ConstellationRenderer と同パターン）、sky_canvas から星座設定の言語を供給
- [x] selected_object_panel / search_service のラベルも言語追従（検索マッチングは従来どおり全言語横断）
- [x] 設定 UI の見出しを 'Name Language (constellations & objects)' に変更（星座名と天体名で共通の設定であることを明示）
- [x] テスト追加: domain 単体（フォールバック規則）＋検索の英語ラベル検証（計 260 テストパス、analyze 0 issues）

---

## Post-implementation retrospective

### Implementation completion date
2026-08-08

### Differences between plan and actual

**Points that differed from the plan**:
- 設計では「TransformationController の逆行列でタップ位置→lon/lat 変換」としたが、GestureDetector を InteractiveViewer の子に置けば localPosition がそのままシーン座標になるため逆行列計算は不要だった（実装を簡素化）
- LandRing は当初 data 層（world_map_loader.dart 内）に定義したが、presentation が data を import する層違反になるため domain/models へ移動（validator 指摘）
- worldMapLoaderProvider は具象型 WorldMapLoader ではなく WorldMapRepository インターフェースで型付けする既存 DI パターンに合わせた（validator 指摘）

**Newly required tasks**:
- Phase 6.5 として implementation-validator の指摘 8 件（Major 3 / Minor 5）を追加対応。既存の AssetDsoRepository 等と同じ CatalogCorruptedException 変換・インターフェース DI・共通ダイアログ化など、「既存パターンとの一貫性」に関するものが大半だった
- control_bar_test に worldMapLoaderProvider のフェイク override を追加（rootBundle の Future は fake-async ゾーンで完了せず、ローディングスピナーが pumpAndSettle をタイムアウトさせるため）

### Lessons learned

**Technical learnings**:
- testWidgets 内では rootBundle のアセットロードが完了しないため、アセット依存ウィジェットを含む画面テストは必ず同期フェイクの loader を override する
- CalendarDatePicker は initialDate を initState でしか読まないため、外部からの日付変更に追従させるには日付で key を張り替える
- DropdownMenu はラベルテキストを複数回レンダリングするので、テストでは find.text ではなく find.byType(DropdownMenu<T>) で特定する
- Natural Earth 50m populated places（1,251 都市）＋110m land を小数2桁に丸めると計 122KB に収まり、オフライン同梱に十分実用的

**Process improvements**:
- 「domain→data→application→presentation」の順で内側から実装し、各フェーズ直後にテストを回すことで手戻りがほぼなかった
- validator サブエージェントが層依存違反・例外変換漏れなど analyze では検出できない一貫性問題を的確に検出した。新層追加を伴う機能では検証を挟む価値が高い

### Improvement suggestions for next time
- 新しいモデル型を data 層のファイル内に「ついで定義」しない。最初から domain/models に置く（今回の LandRing の手戻りの原因）
- リポジトリ実装を追加するときは、まず domain/repositories のインターフェースから書き始めると既存 DI パターンから外れない
- location_section.dart が 373 行まで成長した。タイムゾーン対応等で拡張する際は _buildPickers / _buildMap のウィジェット分割から着手する
