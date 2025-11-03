# -----------------------------
# run-mainnet.ps1
# -----------------------------
# PowerShell script to run Stellar Quickstart Mainnet ready for transactions
# -----------------------------

# 1️⃣ Tentukan folder lokal untuk konfigurasi Stellar
$localDir = "C:/Users/admin/stellar-config"

if (-Not (Test-Path $localDir)) {
    Write-Host "Membuat folder konfigurasi: $localDir"
    New-Item -ItemType Directory -Path $localDir | Out-Null
}

# 2️⃣ Tentukan password PostgreSQL
$pgPassword = "stellar123"

# 3️⃣ Hapus container lama kalau ada
if (docker ps -a --format "{{.Names}}" | Select-String "mainnet-node") {
    Write-Host "Menghapus container lama mainnet-node..."
    docker rm -f mainnet-node | Out-Null
}

# 4️⃣ Jalankan Stellar Quickstart mainnet
Write-Host "Menjalankan Stellar Quickstart mainnet container..."
docker run -d --name mainnet-node `
    -p 31401:8000 `
    -v "${localDir}:/opt/stellar/config" `
    -e "NETWORK=pubnet" `
    -e "POSTGRES_PASSWORD=${pgPassword}" `
    stellar/quickstart:latest

# 5️⃣ Tunggu hingga Horizon siap
Write-Host "Menunggu Horizon siap dan sinkron dengan ledger mainnet..."
while ($true) {
    Start-Sleep -Seconds 15
    try {
        $status = Invoke-RestMethod -Uri "http://localhost:31401" -Method Get
        if ($status._links) {
            Write-Host "Horizon siap! Endpoint JSON siap digunakan."
            break
        }
    } catch {
        Write-Host "Menunggu Horizon... (ledger belum sinkron)"
    }
}

# 6️⃣ Informasi akses
Write-Host "`n✅ Container dijalankan dan siap untuk transaksi!"
Write-Host "Horizon API: http://localhost:31401"
Write-Host "Folder konfigurasi: $localDir"
Write-Host "PostgreSQL password: $pgPassword"

# 7️⃣ Contoh: tampilkan JSON status ledger
Write-Host "`nContoh status ledger terbaru dari Horizon:"
Invoke-RestMethod -Uri "http://localhost:31401" -Method Get | ConvertTo-Json -Depth 5
