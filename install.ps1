# social-creator installer for Windows (PowerShell 5.1+)
#
#   irm https://raw.githubusercontent.com/genai-io/social-creator/main/install.ps1 | iex
#
# Pass options with the scriptblock form:
#   & ([scriptblock]::Create((irm https://raw.githubusercontent.com/genai-io/social-creator/main/install.ps1))) -User
#   & ([scriptblock]::Create((irm .../install.ps1))) -Dir C:\path\to\project
#
# Default scope is the current project (<cwd>\.san). -User installs to ~\.san.

param(
    [switch]$User,
    [string]$Dir = '.'
)

$ErrorActionPreference = 'Stop'

$Persona = 'social-creator'
$RepoUrl = if ($env:SOCIAL_CREATOR_REPO) { $env:SOCIAL_CREATOR_REPO } else { 'https://github.com/genai-io/social-creator.git' }
$Ref     = if ($env:SOCIAL_CREATOR_REF)  { $env:SOCIAL_CREATOR_REF }  else { 'main' }

function Info($m) { Write-Host $m -ForegroundColor Green }
function Fail($m) { Write-Host $m -ForegroundColor Red; exit 1 }

# Resolve the .san config dir by scope.
if ($User) {
    $ConfDir = Join-Path $HOME '.san'
} else {
    $ConfDir = Join-Path ((Resolve-Path $Dir).Path) '.san'
}

# Resolve the source root holding the persona files (system\, skills\,
# settings.json) — the repo root for a checkout, else a fresh clone.
$Tmp = $null
if ($PSScriptRoot -and (Test-Path (Join-Path $PSScriptRoot 'settings.json'))) {
    $SrcRoot = $PSScriptRoot
} else {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) { Fail 'git is required for remote install' }
    $Tmp = Join-Path ([System.IO.Path]::GetTempPath()) ('social-creator-' + [System.Guid]::NewGuid().ToString('N'))
    Info "-> fetching $Persona@$Ref"
    git clone --depth 1 --branch $Ref --quiet $RepoUrl $Tmp
    $SrcRoot = $Tmp
}

# Copy the persona content into <confdir>\personas\social-creator.
$Dest = Join-Path (Join-Path $ConfDir 'personas') $Persona
if (Test-Path $Dest) { Remove-Item -Recurse -Force $Dest }
New-Item -ItemType Directory -Force -Path $Dest | Out-Null
$copied = $false
foreach ($item in @('system', 'skills', 'settings.json')) {
    $p = Join-Path $SrcRoot $item
    if (Test-Path $p) { Copy-Item -Recurse -Force $p $Dest; $copied = $true }
}
if (-not $copied) { Fail "no persona content found in $SrcRoot" }
Info "-> installed persona to $Dest"

# Enable: set "persona" in <confdir>\settings.json, preserving other keys.
$Settings = Join-Path $ConfDir 'settings.json'
if (Test-Path $Settings) {
    try { $data = Get-Content -Raw $Settings | ConvertFrom-Json } catch { $data = [pscustomobject]@{} }
} else {
    $data = [pscustomobject]@{}
}
$data | Add-Member -NotePropertyName persona -NotePropertyValue $Persona -Force
$json = $data | ConvertTo-Json -Depth 20
# UTF-8 without BOM — a BOM would make Go's JSON parser reject the file.
[System.IO.File]::WriteAllText($Settings, $json + "`n", (New-Object System.Text.UTF8Encoding($false)))
Info "-> enabled '$Persona' in $Settings"

if ($Tmp -and (Test-Path $Tmp)) { Remove-Item -Recurse -Force $Tmp }

Write-Host ''
Info '[OK] social-creator installed & enabled'
Write-Host "  Persona:  $Dest"
Write-Host "  Enabled:  $Settings  ->  persona = $Persona"
Write-Host ''
Write-Host "Start san in this directory; switch with  /persona $Persona  (or /persona default)."
