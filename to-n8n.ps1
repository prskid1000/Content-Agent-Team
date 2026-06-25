<#
.SYNOPSIS
  One-time import: this folder  ->  n8n  (load every *.json here into n8n).
.EXAMPLE
  .\to-n8n.ps1
#>
[CmdletBinding()]
param([string]$Folder = $PSScriptRoot)

$ErrorActionPreference = 'Stop'

# n8n CLI talks to the SQLite DB directly; stop the server first to avoid locks.
Get-CimInstance Win32_Process -Filter "name='node.exe'" |
  Where-Object { $_.CommandLine -match 'n8n' } |
  ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
Start-Sleep -Seconds 1

Write-Host "[*] Importing *.json from $Folder into n8n..." -ForegroundColor Cyan
n8n import:workflow --separate --input="$Folder"
Write-Host "[+] Done. Start n8n to use them." -ForegroundColor Green
