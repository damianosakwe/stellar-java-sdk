@echo off
REM Stellar Forge SDK - Contract Deployment Script for Windows
REM This script builds and deploys the contract to Stellar Testnet

echo === Stellar Forge SDK - Contract Deployment ===
echo.

REM Check if soroban is installed
where soroban >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Soroban CLI not found. Install it with:
    echo    cargo install --locked soroban-cli --features opt
    exit /b 1
)

echo [Step 1] Building contract...
cargo build --target wasm32-unknown-unknown --release
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Build failed
    exit /b 1
)
echo [SUCCESS] Contract built
echo.

echo [Step 2] Optimizing WASM...
soroban contract optimize --wasm target\wasm32-unknown-unknown\release\stellar_forge_sdk_contract.wasm
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Optimization failed
    exit /b 1
)
echo [SUCCESS] WASM optimized
echo.

REM Check if network is configured
soroban config network ls | findstr "testnet" >nul
if %ERRORLEVEL% NEQ 0 (
    echo [Step 3] Configuring testnet...
    soroban config network add --global testnet --rpc-url https://soroban-testnet.stellar.org:443 --network-passphrase "Test SDF Network ; September 2015"
    echo [SUCCESS] Testnet configured
    echo.
)

REM Check if deployer identity exists
soroban keys ls | findstr "deployer" >nul
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] No 'deployer' identity found
    echo Creating new identity...
    soroban keys generate deployer --network testnet
    echo.
    echo [WARNING] Please fund this account:
    soroban keys address deployer
    echo.
    echo Visit: https://laboratory.stellar.org/#account-creator?network=test
    echo Or use friendbot:
    for /f %%i in ('soroban keys address deployer') do set DEPLOYER_ADDR=%%i
    echo    curl "https://friendbot.stellar.org?addr=%DEPLOYER_ADDR%"
    echo.
    pause
)

echo [Step 3] Deploying contract to testnet...
for /f %%i in ('soroban contract deploy --wasm target\wasm32-unknown-unknown\release\stellar_forge_sdk_contract.optimized.wasm --source deployer --network testnet') do set CONTRACT_ID=%%i
echo [SUCCESS] Contract deployed!
echo.
echo Contract ID: %CONTRACT_ID%
echo.

REM Save contract ID
echo %CONTRACT_ID% > deployed_contract_id.txt
echo Contract ID saved to: deployed_contract_id.txt
echo.

echo [Step 4] Initializing contract...
for /f %%i in ('soroban keys address deployer') do set OWNER=%%i

soroban contract invoke --id %CONTRACT_ID% --source deployer --network testnet -- initialize --name "Stellar Java SDK" --version "1.0.0" --organization "StellarForge" --group_id "io.stellarforge" --artifact_id "stellar-java-sdk" --repository "https://github.com/damianosakwe/stellar-java-sdk" --description "Comprehensive Java SDK for building on the Stellar network" --owner "%OWNER%"
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Initialization failed
    exit /b 1
)
echo [SUCCESS] Contract initialized!
echo.

echo [Step 5] Verifying deployment...
echo.

echo SDK Info:
soroban contract invoke --id %CONTRACT_ID% --network testnet -- get_sdk_info
echo.

echo Statistics:
soroban contract invoke --id %CONTRACT_ID% --network testnet -- get_stats
echo.

echo === Deployment Complete! ===
echo.
echo Contract ID: %CONTRACT_ID%
echo Network: Testnet
echo Owner: %OWNER%
echo.
echo View on Stellar Expert:
echo   https://stellar.expert/explorer/testnet/contract/%CONTRACT_ID%
echo.
echo Query contract:
echo   soroban contract invoke --id %CONTRACT_ID% --network testnet -- get_sdk_info
echo.
echo Update contract info in your repository:
echo   1. Update README.md with contract ID
echo   2. Create CONTRACT_INFO.md with deployment details
echo   3. Commit and push changes
echo.
