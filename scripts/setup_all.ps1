# SmartRail one-time setup (run in PowerShell as Administrator for MySQL service)

$ErrorActionPreference = "Stop"
$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
if (-not (Test-Path "$root\database\schema.sql")) { $root = "C:\SmartRailAI" }

$py = "$env:LocalAppData\Programs\Python\Python312\python.exe"
$mysqlBin = "C:\Program Files\MySQL\MySQL Server 8.4\bin"
$mysqlData = "C:\ProgramData\MySQL\MySQL Server 8.4\Data"

Write-Host "=== SmartRail setup ===" -ForegroundColor Cyan

# PATH helpers
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
$add = @(
  "$env:LocalAppData\Programs\Python\Python312",
  "$env:LocalAppData\Programs\Python\Python312\Scripts",
  "C:\Program Files\Git\cmd",
  "C:\flutter\bin",
  $mysqlBin
)
foreach ($p in $add) {
  if ((Test-Path $p) -and ($userPath -notlike "*$p*")) {
    $userPath = "$p;$userPath"
  }
}
[Environment]::SetEnvironmentVariable("Path", $userPath, "User")
$env:Path = ($add -join ";") + ";" + $env:Path

# Python venv + deps
Set-Location $root
if (-not (Test-Path ".venv")) { & $py -m venv .venv }
.\.venv\Scripts\python.exe -m pip install -q -r backend\requirements.txt

# AI model
Set-Location "$root\ai"
..\.venv\Scripts\python.exe generate_dataset.py
..\.venv\Scripts\python.exe train_model.py

# MySQL initialize (first run only)
if (-not (Test-Path $mysqlData)) {
  Write-Host "Initializing MySQL data directory (empty root password for demo)..."
  New-Item -ItemType Directory -Force -Path (Split-Path $mysqlData -Parent) | Out-Null
  & "$mysqlBin\mysqld.exe" --initialize-insecure --datadir="$mysqlData" --console
}

$svc = Get-Service -Name "MySQL84" -ErrorAction SilentlyContinue
if (-not $svc) {
  Write-Host "Installing MySQL Windows service (needs Admin)..."
  & "$mysqlBin\mysqld.exe" --install MySQL84 --datadir="$mysqlData"
}
Start-Service MySQL84 -ErrorAction SilentlyContinue

Start-Sleep -Seconds 3
& "$mysqlBin\mysql.exe" -u root -e "SOURCE $root/database/schema.sql"

Set-Location "$root\backend"
..\.venv\Scripts\python.exe seed.py

Write-Host ""
Write-Host "Done. Start API:" -ForegroundColor Green
Write-Host "  cd C:\SmartRailAI\backend"
Write-Host "  ..\.venv\Scripts\python.exe app.py"
Write-Host ""
Write-Host "Demo logins: ADMIN001/Admin@123  INSP001/Inspect@123  MAINT001/Maint@123"
