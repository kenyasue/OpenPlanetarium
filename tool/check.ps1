# Local verification script (equivalent to the CI checks in docs/development-guidelines.md)
# Usage: pwsh tool/check.ps1
$ErrorActionPreference = 'Stop'

Write-Host '=== 1/3 dart format ===' -ForegroundColor Cyan
dart format --set-exit-if-changed lib test tool 2>&1 | Out-Host
if ($LASTEXITCODE -ne 0) { Write-Error 'format violations found'; exit 1 }

Write-Host '=== 2/3 flutter analyze ===' -ForegroundColor Cyan
flutter analyze
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host '=== 3/3 flutter test ===' -ForegroundColor Cyan
flutter test
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host 'ALL CHECKS PASSED' -ForegroundColor Green
