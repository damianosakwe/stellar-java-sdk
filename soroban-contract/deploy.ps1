# PowerShell Deployment Script for Stellar Forge SDK Contract

Write-Host "=== Stellar Forge SDK - Contract Deployment ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Build the contract
Write-Host "[Step 1] Building contract..." -ForegroundColor Blue
soroban contract build
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Build failed" -ForegroundColor Red
    exit 1
}
Write-Host "[SUCCESS] Contract built" -ForegroundColor Green
Write-Host ""

# Step 2: Optimize (optional, soroban contract build already optimizes)
Write-Host "[Step 2] Contract is optimized by default with soroban contract build" -ForegroundColor Blue
Write-Host ""

# Step 3: Configure testnet
Write-Host "[Step 3] Configuring testnet..." -ForegroundColor Blue
$networks = soroban config network ls
if ($networks -notmatch "testnet") {
    soroban config network add --global testnet --rpc-url https://soroban-testnet.stellar.org:443 --network-passphrase "Test SDF Network ; September 2015"
    Write-Host "[SUCCESS] Testnet configured" -ForegroundColor Green
} else {
    Write-Host "[INFO] Testnet already configured" -ForegroundColor Yellow
}
Write-Host ""

# Step 4: Check for deployer identity
Write-Host "[Step 4] Checking deployer identity..." -ForegroundColor Blue
$keys = soroban keys ls
if ($keys -notmatch "deployer") {
    Write-Host "[INFO] Creating new deployer identity..." -ForegroundColor Yellow
    soroban keys generate deployer --network testnet
    $address = soroban keys address deployer
    Write-Host ""
    Write-Host "[WARNING] Please fund this account:" -ForegroundColor Yellow
    Write-Host $address -ForegroundColor White
    Write-Host ""
    Write-Host "Option 1 - Use friendbot (PowerShell):" -ForegroundColor Cyan
    Write-Host "  Invoke-WebRequest -Uri `"https://friendbot.stellar.org?addr=$address`"" -ForegroundColor White
    Write-Host ""
    Write-Host "Option 2 - Use Laboratory:" -ForegroundColor Cyan
    Write-Host "  https://laboratory.stellar.org/#account-creator?network=test" -ForegroundColor White
    Write-Host ""
    Read-Host "Press Enter after funding the account"
} else {
    Write-Host "[SUCCESS] Deployer identity exists" -ForegroundColor Green
}
Write-Host ""

# Step 5: Deploy
Write-Host "[Step 5] Deploying contract to testnet..." -ForegroundColor Blue
$wasmPath = "target\wasm32v1-none\release\stellar_forge_sdk_contract.wasm"
$CONTRACT_ID = soroban contract deploy --wasm $wasmPath --source deployer --network testnet
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Deployment failed" -ForegroundColor Red
    exit 1
}
Write-Host "[SUCCESS] Contract deployed!" -ForegroundColor Green
Write-Host ""
Write-Host "Contract ID: $CONTRACT_ID" -ForegroundColor Cyan
Write-Host ""

# Save contract ID
$CONTRACT_ID | Out-File -FilePath "deployed_contract_id.txt" -Encoding ASCII
Write-Host "Contract ID saved to: deployed_contract_id.txt" -ForegroundColor Green
Write-Host ""

# Step 6: Initialize
Write-Host "[Step 6] Initializing contract..." -ForegroundColor Blue
$OWNER = soroban keys address deployer

soroban contract invoke `
  --id $CONTRACT_ID `
  --source deployer `
  --network testnet `
  -- `
  initialize `
  --name "Stellar Java SDK" `
  --version "1.0.0" `
  --organization "StellarForge" `
  --group_id "io.stellarforge" `
  --artifact_id "stellar-java-sdk" `
  --repository "https://github.com/damianosakwe/stellar-java-sdk" `
  --description "Comprehensive Java SDK for building on the Stellar network" `
  --owner $OWNER

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Initialization failed" -ForegroundColor Red
    exit 1
}
Write-Host "[SUCCESS] Contract initialized!" -ForegroundColor Green
Write-Host ""

# Step 7: Verify
Write-Host "[Step 7] Verifying deployment..." -ForegroundColor Blue
Write-Host ""

Write-Host "SDK Info:" -ForegroundColor Cyan
soroban contract invoke --id $CONTRACT_ID --network testnet -- get_sdk_info
Write-Host ""

Write-Host "Statistics:" -ForegroundColor Cyan
soroban contract invoke --id $CONTRACT_ID --network testnet -- get_stats
Write-Host ""

Write-Host "=== Deployment Complete! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Contract ID: $CONTRACT_ID" -ForegroundColor Cyan
Write-Host "Network: Testnet" -ForegroundColor Cyan
Write-Host "Owner: $OWNER" -ForegroundColor Cyan
Write-Host ""
Write-Host "View on Stellar Expert:" -ForegroundColor Yellow
Write-Host "  https://stellar.expert/explorer/testnet/contract/$CONTRACT_ID" -ForegroundColor White
Write-Host ""
Write-Host "Query contract:" -ForegroundColor Yellow
Write-Host "  soroban contract invoke --id $CONTRACT_ID --network testnet -- get_sdk_info" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Update README.md with contract ID" -ForegroundColor White
Write-Host "  2. Create CONTRACT_INFO.md with deployment details" -ForegroundColor White
Write-Host "  3. Commit and push changes" -ForegroundColor White
Write-Host ""
