<#
.SYNOPSIS
  One-time export: n8n  ->  this folder  (write every n8n workflow here as
  <Workflow Name>.json, matching this repo's naming).
.EXAMPLE
  .\fro-n8n.ps1
#>
[CmdletBinding()]
param([string]$Folder = $PSScriptRoot)

$ErrorActionPreference = 'Stop'

# n8n CLI talks to the SQLite DB directly; stop the server first to avoid locks.
Get-CimInstance Win32_Process -Filter "name='node.exe'" |
  Where-Object { $_.CommandLine -match 'n8n' } |
  ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
Start-Sleep -Seconds 1

function Sanitize([string]$name) {
  $invalid = [IO.Path]::GetInvalidFileNameChars() -join ''
  $re = "[{0}]" -f [Regex]::Escape($invalid)
  ($name -replace $re, '_').Trim()
}

$tmp = Join-Path $env:TEMP ("n8n-export-" + [Guid]::NewGuid().ToString('N').Substring(0,8))
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
try {
  Write-Host "[*] Exporting all workflows from n8n..." -ForegroundColor Cyan
  n8n export:workflow --all --separate --pretty --output="$tmp" | Out-Null
  $files = Get-ChildItem $tmp -Filter *.json
  Write-Host "[*] Writing $($files.Count) workflows to $Folder as <name>.json..." -ForegroundColor Cyan
  $used = @{}
  foreach ($f in $files) {
    $obj  = Get-Content $f.FullName -Raw | ConvertFrom-Json
    $name = Sanitize $obj.name
    if ([string]::IsNullOrWhiteSpace($name)) { $name = $obj.id }
    if ($used.ContainsKey($name)) { $name = "$name ($($obj.id))" }   # disambiguate same names
    $used[$name] = $true
    Copy-Item $f.FullName (Join-Path $Folder "$name.json") -Force
  }
  Write-Host "[+] Done -> $Folder" -ForegroundColor Green
} finally {
  Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
}
