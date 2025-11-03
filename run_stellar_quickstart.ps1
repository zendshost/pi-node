$NODE_NAME = "mainnet-node"
$PORT_HORIZON = 31401
$PORT_CORE = 11626
$STELLAR_HOME = "C:\stellar"

Write-Host "[1/3] Menarik image stellar/quickstart:latest..."
docker pull stellar/quickstart:latest

Write-Host "[2/3] Menjalankan container node Stellar..."
docker run -d --rm `
  --name $NODE_NAME `
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

Write-Host "[3/3] Node sedang dijalankan..."
Write-Host "Gunakan perintah berikut untuk melihat log:"
Write-Host "   docker logs -f $NODE_NAME"
Write-Host ""
Write-Host "Akses Horizon API di:"
Write-Host "   http://localhost:$PORT_HORIZON"
