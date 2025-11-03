# =======================================================
# Script: run_pi_mainnet_node.ps1
# Tujuan: Menjalankan node Pi Network Mainnet siap transaksi
# Port Horizon: 31401
# =======================================================

$ErrorActionPreference = "Stop"

# Konfigurasi utama
$NODE_NAME = "pi-mainnet"
$PORT_HORIZON = 31401
$PORT_CORE = 11626
$DATA_DIR = "C:\Users\admin\AppData\Roaming\PiNetwork\mainnet-data"
$POSTGRES_PASSWORD = "stellar"
$NETWORK_PASSPHRASE = "Pi Network"
$HISTORY_URL = "http://4.194.35.14:31403"   # History archive Pi Mainnet

Write-Host "`n🚀 Menjalankan Pi Network Mainnet Node (Siap Transaksi)" -ForegroundColor Cyan

# 1️⃣ Buat folder data
if (-Not (Test-Path $DATA_DIR)) {
    New-Item -ItemType Directory -Force -Path $DATA_DIR | Out-Null
}

# 2️⃣ Tarik image Stellar Quickstart
Write-Host "`n📦 Mengunduh image stellar/quickstart:latest..."
docker pull stellar/quickstart:latest

# 3️⃣ Hentikan container lama jika ada
if ($(docker ps -a -q -f name=$NODE_NAME)) {
    Write-Host "`n🧹 Menghapus container lama..."
    docker stop $NODE_NAME | Out-Null
    docker rm $NODE_NAME | Out-Null
}

# 4️⃣ Jalankan container dengan konfigurasi Pi Network
Write-Host "`n🚀 Menjalankan container $NODE_NAME..."
docker run -d --name $NODE_NAME `
  -e NETWORK="$NETWORK_PASSPHRASE" `
  -e DATABASE_PASSWORD="$POSTGRES_PASSWORD" `
  -e ENABLE_CORE="true" `
  -e ENABLE_HORIZON="true" `
  -e HISTORY_ARCHIVE_URLS="$HISTORY_URL" `
  -p ${PORT_HORIZON}:8000 `
  -p ${PORT_CORE}:11626 `
  -v "${DATA_DIR}:/opt/stellar" `
  stellar/quickstart:latest

# 5️⃣ Tampilkan status container
Write-Host "`n✅ Container sedang berjalan..."
docker ps | findstr $NODE_NAME

Write-Host "`n🔍 Mengecek status sinkronisasi (Horizon)..."
for ($i=1; $i -le 60; $i++) {
    Start-Sleep -Seconds 30
    try {
        $res = Invoke-RestMethod -Uri "http://localhost:$PORT_HORIZON" -TimeoutSec 10
        if ($res.core_latest_ledger -gt 0 -and $res.ingest_latest_ledger -gt 0) {
            Write-Host "`n✅ Horizon sudah siap! Node sinkron sepenuhnya." -ForegroundColor Green
            Write-Host "🌍 URL: http://localhost:$PORT_HORIZON" -ForegroundColor Cyan
            break
        }
    } catch {}
    Write-Host "⏳ Menunggu sinkronisasi... ($i/60)"
}

Write-Host "`n📜 Cek JSON hasil di browser:"
Write-Host "👉 http://localhost:$PORT_HORIZON/" -ForegroundColor Yellow
Write-Host "`n📡 Jika ingin lihat log real-time:"
Write-Host "docker logs -f $NODE_NAME" -ForegroundColor Gray
