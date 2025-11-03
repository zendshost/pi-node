# run_stellar_pi.ps1
# Script untuk menjalankan Stellar Pi Network Quickstart di Windows menggunakan Docker

# ============================
# CONFIGURASI
# ============================
$containerName = "pi-node"
$imageName = "stellar/quickstart:latest"
$networkPassphrase = "Pi Network"
$portHorizon = 31401

# Buat direktori config lokal
$localDir = "$PSScriptRoot\stellar_data"
if (!(Test-Path $localDir)) {
    New-Item -ItemType Directory -Path $localDir
}

# ============================
# File konfigurasi stellar-core.cfg
# ============================
$coreCfgPath = "$localDir\stellar-core.cfg"
$coreCfgContent = @"
# Stellar Pi Network core config
NETWORK_PASSPHRASE="$networkPassphrase"
NODE_SEED="SB5MGOMXKRHDC5OSM26QEJBZWIWNWFSQRQARMPZG4XFSUPQQIWUXTVO6"  # Ganti dengan seed node kamu
RUN_STANDALONE=false
HTTP_PORT=11626
PUBLIC_HTTP_PORT=true
ARTIFICIALLY_ACCELERATE_TIME_FOR_TESTING=false
DATABASE="postgresql://stellar:stellar@localhost:5432/stellar"
"@

# Simpan file tanpa BOM
$coreCfgContent | Out-File -FilePath $coreCfgPath -Encoding ascii

# ============================
# Jalankan container
# ============================
# Hapus container lama jika ada
if (docker ps -a --format '{{.Names}}' | Select-String $containerName) {
    Write-Host "Menghapus container lama $containerName..."
    docker rm -f $containerName
}

# Run container Stellar Quickstart
Write-Host "Menjalankan Stellar Pi Network container..."
docker run -d `
    --name $containerName `
    -p $portHorizon:8000 `
    -v "$localDir:/opt/stellar/config" `
    -e "NETWORK_PASSPHRASE=$networkPassphrase" `
    -e "NODE_SEED=SB5MGOMXKRHDC5OSM26QEJBZWIWNWFSQRQARMPZG4XFSUPQQIWUXTVO6" `
    $imageName

# ============================
# Tampilkan logs
# ============================
Write-Host "Menunggu container startup dan menampilkan log..."
docker logs -f $containerName
