# Packages plugins/butler into dist/butler.zip for upload to claude.ai.
# The zip root contains .claude-plugin/ and skills/ directly; entry names use "/" separators.
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$src  = (Resolve-Path (Join-Path $root 'plugins\butler')).Path
$dist = Join-Path $root 'dist'
$zip  = Join-Path $dist 'butler.zip'
$v = (Get-Content (Join-Path $src '.claude-plugin\plugin.json') -Raw | ConvertFrom-Json).version
# Every "butler X.Y.Z" in the skills (written into the KB as written-by) must match plugin.json.
$bad = Get-ChildItem -Path (Join-Path $src 'skills') -Recurse -Filter 'SKILL.md' |
  Select-String -Pattern 'butler (\d+\.\d+\.\d+)' -AllMatches |
  ForEach-Object { foreach ($m in $_.Matches) { if ($m.Groups[1].Value -ne $v) { "$($_.Path):$($_.LineNumber) has butler $($m.Groups[1].Value)" } } }
if ($bad) { throw "Skill version mismatch with plugin.json ($v):`n$($bad -join "`n")" }
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
Write-Host "Built $zip (version $v)"
