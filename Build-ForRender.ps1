#Requires -Version 5.1
<#
  Flutter Web release build, copy to backend/static/web for Flask on same Render URL.

  Usage:
    .\Build-ForRender.ps1
    .\Build-ForRender.ps1 -BaseHref "/app/"
    .\Build-ForRender.ps1 -SkipCopy

  After build: git add backend/static/web if you commit the bundle.
#>

param(
    [string]$BaseHref = "/",
    [switch]$SkipCopy
)

$ErrorActionPreference = "Stop"
$Root = $PSScriptRoot
Set-Location $Root

function Test-Cmd([string]$Name) {
    [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

if (-not (Test-Cmd "flutter")) {
    Write-Error "Flutter not in PATH. Install Flutter and run: flutter config --enable-web"
}

$bh = $BaseHref.Trim()
if (-not $bh.StartsWith("/")) { $bh = "/$bh" }
if (-not $bh.EndsWith("/")) { $bh = "$bh/" }

$webOut = Join-Path $Root "build\web"
$staticTarget = Join-Path $Root "backend\static\web"

Write-Host "==> Courage Quest root: $Root" -ForegroundColor Cyan
Write-Host "==> flutter pub get ; flutter build web --release --no-tree-shake-icons --base-href $bh" -ForegroundColor Cyan

Push-Location $Root
try {
    flutter pub get
    flutter build web --release --no-tree-shake-icons --base-href $bh
}
finally {
    Pop-Location
}

if (-not (Test-Path $webOut)) {
    Write-Error "build\web missing after build. Check flutter output."
}

if (-not $SkipCopy) {
    Write-Host "==> Copy build\web -> backend\static\web" -ForegroundColor Green
    New-Item -ItemType Directory -Force -Path $staticTarget | Out-Null
    Get-ChildItem -Path $staticTarget -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force
    Copy-Item -Path (Join-Path $webOut "*") -Destination $staticTarget -Recurse -Force
    Write-Host "==> Done. Bundle: $staticTarget" -ForegroundColor Green
    Write-Host "==> Reminder: git add backend/static/web before push if you version the bundle." -ForegroundColor Yellow
}
else {
    Write-Host "==> Build only, no copy: $webOut" -ForegroundColor Green
}
