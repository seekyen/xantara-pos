$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
Push-Location $projectRoot
try {
  & '.\.tools\flutter\bin\flutter.bat' build web --release --no-wasm-dry-run --dart-define=API_BASE_URL=http://127.0.0.1:8086 --output build/web-device-preview
  if ($LASTEXITCODE -ne 0) { throw 'Flutter preview build failed.' }
  & node (Join-Path $PSScriptRoot 'serve-local-preview.cjs')
} finally {
  Pop-Location
}
