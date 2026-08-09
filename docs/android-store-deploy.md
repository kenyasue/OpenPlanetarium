# Google Play Deployment Guide

Automated pipeline: **GitHub Actions → signed AAB build → fastlane supply →
Google Play**. Store listing text/screenshots live in
`android/fastlane/metadata/android/` (generated from `store-assets/app.md`).

After the one-time setup below, every deployment is a single click:
**GitHub → Actions → "Deploy to Google Play" → Run workflow** (track:
`internal` to test, `production` to release).

---

## One-time setup (manual — cannot be automated)

### 1. Create the app in Play Console

Google provides no API for app creation.

1. https://play.google.com/console → **Create app**
2. Name: `Open Planetarium` / Default language: `en-US` /
   App or game: **App** / Free
3. Complete the **Set up your app** checklist (all Console-only):
   - **Privacy policy** — URL required (publish one first; see
     `store-assets/app.md` TODO)
   - **App access** — "All functionality is available without special access"
   - **Ads** — No
   - **Content rating** questionnaire — answers in `store-assets/app.md`
     (all No → rated 3+)
   - **Target audience** — 13+ recommended (avoids Families policy)
   - **Data safety** — "No data collected or shared" (location is on-device
     only; see `store-assets/app.md` for the full answers)

### 2. Create the upload keystore

```powershell
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -genkeypair -v `
  -keystore E:\Users\ken\keys\openplanetarium-upload.jks `
  -alias openplanetarium -keyalg RSA -keysize 4096 -validity 10000
```

Keep the .jks and passwords outside the repo (e.g. `E:\Users\ken\keys\`,
same place as the monstermath key). The repo ignores `*.jks` /
`key.properties`.

### 3. Create a service account (API access)

1. Play Console → **Users and permissions** → API access (or directly in
   Google Cloud Console) → create/link a Cloud project
2. Enable the **Google Play Android Developer API** in that project
3. IAM → **Service Accounts** → Create (e.g. `play-deploy`) →
   **Keys → Add key → JSON** → download the JSON file
4. Play Console → **Users and permissions → Invite new users** → the service
   account email → grant **Release manager** (Releases + Store presence
   permissions) for Open Planetarium

### 4. First upload (manual, once)

fastlane/the API **cannot create the very first release** of a new app:

```powershell
flutter build appbundle --release   # with android/key.properties in place (see below)
```

Play Console → **Testing → Internal testing → Create release** → upload
`build\app\outputs\bundle\release\app-release.aab`. Accept **Play App
Signing** enrollment when prompted (your .jks becomes the upload key).

Local `android/key.properties` (gitignored) for local release builds:

```properties
storeFile=E:\\Users\\ken\\keys\\openplanetarium-upload.jks
storePassword=<store password>
keyAlias=openplanetarium
keyPassword=<key password>
```

### 5. GitHub repository secrets

GitHub → Settings → Secrets and variables → Actions → **New repository
secret**:

| Secret | Value |
|---|---|
| `PLAY_SERVICE_ACCOUNT_JSON` | Contents of the service-account JSON file |
| `ANDROID_KEYSTORE_BASE64` | `[Convert]::ToBase64String([IO.File]::ReadAllBytes('E:\Users\ken\keys\openplanetarium-upload.jks'))` の出力 |
| `ANDROID_KEYSTORE_PASSWORD` | keystore password |
| `ANDROID_KEY_ALIAS` | `openplanetarium` |
| `ANDROID_KEY_PASSWORD` | key password |

---

## Every release after that (automated)

1. Bump `version:` in `pubspec.yaml` (e.g. `0.3.0+3` — Play requires a new
   build number every upload)
2. Add changelogs:
   `android/fastlane/metadata/android/{en-US,ja-JP}/changelogs/<build>.txt`
3. Commit & push
4. GitHub → Actions → **Deploy to Google Play** → Run workflow →
   track `internal`
5. Verify on a device via the internal-testing link, then re-run with track
   `production` (or promote in Play Console)

The workflow uploads the AAB **and** syncs the store listing (title,
descriptions, changelogs, icon, screenshots) from
`android/fastlane/metadata/android/`. Screenshots live only under `en-US`
(the default listing); other locales inherit them.

## Updating the store listing only

Edit files under `android/fastlane/metadata/android/` (keep
`store-assets/app.md` in sync — it is the human-readable source of truth)
and re-run the workflow; supply pushes listing changes even without a new
build number... but a new AAB is always uploaded, so bump the build number
anyway to keep it simple.
