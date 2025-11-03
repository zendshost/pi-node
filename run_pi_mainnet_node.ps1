# Path project
$ProjectPath = "C:\Users\admin\stellar-pi"
$configPath = Join-Path $ProjectPath "config"
$cfgFile = Join-Path $configPath "stellar-core.cfg"

# Buat folder project & config
if (!(Test-Path $configPath)) {
    Write-Host "Creating project folders..."
    New-Item -ItemType Directory -Path $configPath -Force
}

# Generate stellar-core.cfg otomatis
Write-Host "Generating stellar-core.cfg for Pi Network..."
$cfgContent = @"
# Stellar Pi Network core config
NETWORK_PASSPHRASE="Pi Network"
NODE_SEED="SB5MGOMXKRHDC5OSM26QEJBZWIWNWFSQRQARMPZG4XFSUPQQIWUXTVO6"
RUN_STANDALONE=false
LEDGER_PROTOCOL=19
DATABASE="postgresql://stellar:stellar@postgres/stellar"
HISTORY="http://4.194.35.14:31403"
CATCHUP_COMPLETE=true
"@

$cfgContent | Set-Content -Path $cfgFile -Encoding UTF8

# Buat Dockerfile otomatis
$dockerFile = Join-Path $ProjectPath "Dockerfile"
Write-Host "Generating Dockerfile..."
$dockerContent = @"
FROM stellar/quickstart:latest

# Copy custom config
COPY config/stellar-core.cfg /opt/stellar/core/etc/stellar-core.cfg
"@

$dockerContent | Set-Content -Path $dockerFile -Encoding UTF8

# Build Docker image
Write-Host "Building Docker image 'stellar-pi'..."
docker build -t stellar-pi $ProjectPath

# Run Docker container
Write-Host "Running Stellar Pi Network container..."
docker run -d --name stellar-pi-node `
  -p 31401:8000 `
  -p 11625:11625 `
  -p 11626:11626 `
  stellar-pi

Write-Host "✅ Stellar Pi Network container is running!"
Write-Host "Horizon available at http://localhost:31401 (or http://<your-ip>:31401)"
