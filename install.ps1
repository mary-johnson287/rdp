# Full Devbox Setup Script – install.ps1

# --- LOG START ---
Write-Host "🔧 Starting Devbox Setup..." -ForegroundColor Cyan

# === 1. Install VSCode ===
try {
    Write-Host "📦 Installing VSCode..."
    Invoke-WebRequest -Uri "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user" -OutFile "$env:TEMP\vscode.exe"
    Start-Process "$env:TEMP\vscode.exe" -ArgumentList "/silent" -Wait
} catch {
    Write-Host "❌ VSCode install failed: $($_.Exception.Message)" -ForegroundColor Red
}

# === 2. Install AnyDesk ===
try {
    Write-Host "📦 Installing AnyDesk..."
    Invoke-WebRequest -Uri "https://download.anydesk.com/AnyDesk.exe" -OutFile "$env:TEMP\AnyDesk.exe"
    Start-Process "$env:TEMP\AnyDesk.exe" -ArgumentList "--install", "C:\Program Files (x86)\AnyDesk\", "--start-with-win", "--silent" -Wait
} catch {
    Write-Host "❌ AnyDesk install failed: $($_.Exception.Message)" -ForegroundColor Red
}

# === 3. Set AnyDesk Password & Unattended Access ===
try {
    Write-Host "🔐 Configuring AnyDesk Access..."
    $anydeskPath = "HKLM:\SOFTWARE\AnyDesk"
    New-Item -Path $anydeskPath -Force | Out-Null
    Set-ItemProperty -Path $anydeskPath -Name "Password" -Value ([System.Text.Encoding]::UTF8.GetBytes("Sumit@123")) -Type Binary
    Set-ItemProperty -Path $anydeskPath -Name "AllowUnattendedAccess" -Value 1 -Type DWord
    Set-ItemProperty -Path $anydeskPath -Name "AlwaysShowAcceptWindow" -Value 0 -Type DWord
} catch {
    Write-Host "❌ AnyDesk config failed: $($_.Exception.Message)" -ForegroundColor Red
}

# === 4. Enable RDP ===
try {
    Write-Host "🖥 Enabling RDP Access..."
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
} catch {
    Write-Host "❌ RDP enabling failed: $($_.Exception.Message)" -ForegroundColor Red
}

# === 5. Firewall Rule for AnyDesk ===
try {
    Write-Host "🔥 Allowing AnyDesk in firewall..."
    New-NetFirewallRule -DisplayName "Allow AnyDesk" -Direction Inbound -Program "C:\Program Files (x86)\AnyDesk\AnyDesk.exe" -Action Allow -Enabled True
} catch {
    Write-Host "❌ Firewall rule failed: $($_.Exception.Message)" -ForegroundColor Red
}

# === 6. Show AnyDesk ID (optional) ===
Start-Sleep -Seconds 5
try {
    $adID = Get-Content "C:\ProgramData\AnyDesk\service.conf" | Select-String "ad.anynet.id" | ForEach-Object { $_ -replace ".*=", "" }
    Write-Host "`n🆔 AnyDesk ID: $adID" -ForegroundColor Cyan
    Write-Host "🔑 Password: Sumit@123" -ForegroundColor Yellow
} catch {
    Write-Host "❌ Could not retrieve AnyDesk ID" -ForegroundColor DarkYellow
}

Write-Host "`n✅ Setup Complete!" -ForegroundColor Green
