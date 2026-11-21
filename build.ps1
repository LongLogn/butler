# Packages plugins/butler into dist/butler.zip for upload to claude.ai.
# The zip root contains .claude-plugin/ and skills/ directly; entry names use "/" separators.
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$src  = (Resolve-Path (Join-Path $root 'plugins\butler')).Path
$dist = Join-Path $root 'dist'
$zip  = Join-Path $dist 'butler.zip'
New-Item -ItemType Directory -Force $dist | Out-Null
if (Test-Path $zip) { Remove-Item $zip -Force }
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::Open($zip, 'Create')
try {
  Get-ChildItem -Path $src -Recurse -File -Force | ForEach-Object {
    $name = $_.FullName.Substring($src.Length + 1).Replace('\', '/')
    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $_.FullName, $name) | Out-Null
  }
} finally { $archive.Dispose() }
$v = (Get-Content (Join-Path $src '.claude-plugin\plugin.json') -Raw | ConvertFrom-Json).version
Write-Host "Built $zip (version $v)"
