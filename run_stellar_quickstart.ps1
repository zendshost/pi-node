# ===========================
# Script: run_stellar_quickstart.ps1
# ===========================
# Jalankan Node Stellar Mainnet dengan Docker (Port 31401)
# By ZendsCode Helper

# Hentikan script saat ada error
$ErrorActionPreference = "Stop"

# Konfigurasi dasar
$NODE_NAME = "mainnet-node"
$PORT_HORIZON = 31401
$PORT_CORE = 11626
$STELLAR_HOME = "C:\Users\admin\AppData\Roaming\Pi Network\docker_volumes\mainnet_node"

Write-Host ""
Write-Host "=============================" -ForegroundColor Cyan
Write-Host " STELLAR NODE MAINNET STARTER" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
Write-Host ""

# 1️⃣ Membuat direktori data jika belum ada
if (-Not (Test-Path $STELLAR_HOME)) {
    Write-Host "[1/5] Membuat direktori data node di $STELLAR_HOME ..."
    New-Item -ItemType Directory -Force -Path $STELLAR_HOME | Out-Null
} else {
    Write-Host "[1/5] Direktori data sudah ada: $STELLAR_HOME"
}

# 2️⃣ Menarik image Stellar terbaru
Write-Host "[2/5] Menarik image stellar/quickstart:latest ..." -ForegroundColor Yellow
docker pull stellar/quickstart:latest

# 3️⃣ Hentikan container lama (jika ada)
if ($(docker ps -a -q -f name=$NODE_NAME)) {
    Write-Host "[3/5] Menghapus container lama ($NODE_NAME) ..." -ForegroundColor Yellow
    docker stop $NODE_NAME | Out-Null
    docker rm $NODE_NAME | Out-Null
}

# 4️⃣ Jalankan container baru
Write-Host "[4/5] Menjalankan container node Stellar Mainnet..." -ForegroundColor Green
docker run -d --name $NODE_NAME `
  -p ${PORT_HORIZON}:8000 `
  -p ${PORT_CORE}:11626 `
  -v "${STELLAR_HOME}:/opt/stellar" `
  stellar/quickstart:latest `
  --pubnet `
  --protocol-version 19 `
  --history-archive-urls "http://4.194.35.14:31403" `
  --postgres-password "stellar" `
  --enable-core `
  --enable-horizon

# 5️⃣ Tampilkan status
Start-Sleep -Seconds 3
Write-Host ""
Write-Host "[5/5] Container berhasil dijalankan!" -ForegroundColor Green
docker ps --filter "name=$NODE_NAME"

Write-Host ""
Write-Host "🌐 Horizon API dapat diakses di: http://localhost:$PORT_HORIZON" -ForegroundColor Cyan
Write-Host "🧩 Core RPC port aktif di: $PORT_CORE" -ForegroundColor Cyan
Write-Host ""
Write-Host "Gunakan perintah ini untuk melihat log realtime:" -ForegroundColor Yellow
Write-Host "    docker logs -f $NODE_NAME" -ForegroundColor White
Write-Host ""
Write-Host "Tunggu proses sinkronisasi hingga 'horizon ingestion complete' muncul." -ForegroundColor Yellow
Write-Host ""
