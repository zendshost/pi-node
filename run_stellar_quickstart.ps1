# ==========================================
# Script: run_stellar_quickstart.ps1
# Jalankan Stellar Node Mainnet (dengan custom history archive)
# By ZendsCode Helper
# ==========================================

$ErrorActionPreference = "Stop"

# Konfigurasi
$NODE_NAME = "mainnet-node"
$PORT_HORIZON = 31401
$PORT_CORE = 11626
$STELLAR_HOME = "C:\Users\admin\AppData\Roaming\Pi Network\docker_volumes\mainnet_node"
$POSTGRES_PASSWORD = "stellar"

# URL sumber history dari node lain (untuk sinkron cepat)
$HISTORY_URL = "http://4.194.35.14:31403"

Write-Host "`n=============================" -ForegroundColor Cyan
Write-Host "  STELLAR MAINNET NODE START  " -ForegroundColor Cyan
Write-Host "=============================`n" -ForegroundColor Cyan

# 1️⃣ Membuat direktori
if (-Not (Test-Path $STELLAR_HOME)) {
    Write-Host "[1/6] Membuat direktori data node di $STELLAR_HOME ..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Force -Path $STELLAR_HOME | Out-Null
} else {
    Write-Host "[1/6] Direktori data sudah ada: $STELLAR_HOME"
}

# 2️⃣ Membuat konfigurasi stellar-core.cfg
Write-Host "[2/6] Membuat file konfigurasi stellar-core.cfg ..." -ForegroundColor Yellow
$configFile = @"
HTTP_PORT=11626
PUBLIC_HTTP_PORT=true
LOG_FILE_PATH=""
NETWORK_PASSPHRASE="Public Global Stellar Network ; September 2015"

DATABASE="postgresql://dbname=core host=localhost user=postgres password=$POSTGRES_PASSWORD"
CATCHUP_RECENT=60480
MAX_CONCURRENT_SUBPROCESSES=10

[HISTORY.local]
get="cp \$history/local/{0} {1}"

[HISTORY.mainnet]
get="$HISTORY_URL/{0}"

[QUORUM_SET]
VALIDATORS=[
"GAXPBP33M2JPQU3D6M7YF4V7FQHGBNSPXLPXRPASLKYHJETJCQF6R5CC", # SDF Validator 1
"GCGB2S2KGYARPVQK7PVKQLB2P6CDJIY2LRQ2AIYGX7ZQ2MFX6Y3ONPUO", # SDF Validator 2
"GBJRY7YWMU3ORFQUBAA4FDDHSDM2NPNW6RMSW6OWDTTM6WJTHW4YLGSH"  # SDF Validator 3
]
THRESHOLD_PERCENT=67
"@

$configPath = Join-Path $STELLAR_HOME "stellar-core.cfg"
$configFile | Out-File -Encoding utf8 -FilePath $configPath -Force

# 3️⃣ Pull image Stellar Quickstart
Write-Host "[3/6] Menarik image stellar/quickstart:latest ..." -ForegroundColor Yellow
docker pull stellar/quickstart:latest

# 4️⃣ Stop & hapus container lama
if ($(docker ps -a -q -f name=$NODE_NAME)) {
    Write-Host "[4/6] Menghapus container lama ($NODE_NAME) ..." -ForegroundColor Yellow
    docker stop $NODE_NAME | Out-Null
    docker rm $NODE_NAME | Out-Null
}

# 5️⃣ Jalankan container baru
Write-Host "[5/6] Menjalankan Stellar Mainnet Node..." -ForegroundColor Green
docker run -d --name $NODE_NAME `
  -p ${PORT_HORIZON}:8000 `
  -p ${PORT_CORE}:11626 `
  -v "${STELLAR_HOME}:/opt/stellar" `
  stellar/quickstart:latest `
  --pubnet `
  --enable-core `
  --enable-horizon `
  --postgres-password $POSTGRES_PASSWORD `
  --restart=always

# 6️⃣ Info status
Start-Sleep -Seconds 3
Write-Host "`n[6/6] Container berjalan!" -ForegroundColor Green
docker ps --filter "name=$NODE_NAME"

Write-Host ""
Write-Host "🌐 Horizon API: http://localhost:$PORT_HORIZON" -ForegroundColor Cyan
Write-Host "🧩 Core RPC Port: $PORT_CORE" -ForegroundColor Cyan
Write-Host ""
Write-Host "Lihat log realtime:  docker logs -f $NODE_NAME" -ForegroundColor Yellow
Write-Host ""
Write-Host "Node akan sinkron ke mainnet menggunakan history dari:" -ForegroundColor Green
Write-Host "➡️  $HISTORY_URL" -ForegroundColor White
Write-Host ""
Write-Host "Tunggu hingga muncul: 'horizon ingestion complete'" -ForegroundColor Cyan
Write-Host ""
