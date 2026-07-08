# Windows Deployment Guide - Stellar Java SDK Smart Contract

This guide helps you deploy the Stellar Forge SDK smart contract from Windows.

## Current Status

✅ **Rust installed** - Version 1.94.0 detected  
🔄 **Soroban CLI installing** - Currently compiling (this takes 10-15 minutes)  
⏳ **Contract ready** - Waiting for Soroban CLI to complete installation  

## Step 1: Wait for Soroban CLI Installation

The Soroban CLI is currently installing. You can check progress by opening a new PowerShell window and running:

```powershell
soroban --version
```

When you see a version number (e.g., `soroban 27.0.0`), the installation is complete.

## Step 2: Add wasm32 Target

After Soroban CLI installs, run:

```powershell
rustup target add wasm32-unknown-unknown
```

## Step 3: Build the Contract

Navigate to the soroban-contract directory and build:

```cmd
cd soroban-contract
cargo build --target wasm32-unknown-unknown --release
```

This creates the WASM file at:
`target\wasm32-unknown-unknown\release\stellar_forge_sdk_contract.wasm`

## Step 4: Optimize the WASM (Optional)

```cmd
soroban contract optimize --wasm target\wasm32-unknown-unknown\release\stellar_forge_sdk_contract.wasm
```

This creates an optimized file:
`target\wasm32-unknown-unknown\release\stellar_forge_sdk_contract.optimized.wasm`

## Step 5: Configure Stellar Testnet

```cmd
soroban config network add --global testnet --rpc-url https://soroban-testnet.stellar.org:443 --network-passphrase "Test SDF Network ; September 2015"
```

## Step 6: Create Deployer Identity

```cmd
soroban keys generate deployer --network testnet
```

Get your address:
```cmd
soroban keys address deployer
```

## Step 7: Fund Your Account

Copy the address from Step 6 and fund it using one of these methods:

### Method A: Friendbot (Easiest)
Open PowerShell and run:
```powershell
$address = soroban keys address deployer
Invoke-WebRequest -Uri "https://friendbot.stellar.org?addr=$address"
```

### Method B: Laboratory
Visit: https://laboratory.stellar.org/#account-creator?network=test  
Paste your address and click "Get test network lumens"

## Step 8: Deploy the Contract

```cmd
soroban contract deploy --wasm target\wasm32-unknown-unknown\release\stellar_forge_sdk_contract.optimized.wasm --source deployer --network testnet
```

**Save the Contract ID** that gets printed! You'll need it for the next step.

## Step 9: Initialize the Contract

Replace `YOUR_CONTRACT_ID` with the actual contract ID from Step 8:

```cmd
soroban contract invoke --id YOUR_CONTRACT_ID --source deployer --network testnet -- initialize --name "Stellar Java SDK" --version "1.0.0" --organization "StellarForge" --group_id "io.stellarforge" --artifact_id "stellar-java-sdk" --repository "https://github.com/damianosakwe/stellar-java-sdk" --description "Comprehensive Java SDK for building on the Stellar network" --owner "YOUR_PUBLIC_KEY"
```

To get YOUR_PUBLIC_KEY:
```cmd
soroban keys address deployer
```

## Step 10: Verify Deployment

Query the contract to see if it worked:

```cmd
soroban contract invoke --id YOUR_CONTRACT_ID --network testnet -- get_sdk_info
```

You should see your SDK information returned!

## Step 11: View on Stellar Expert

Visit: `https://stellar.expert/explorer/testnet/contract/YOUR_CONTRACT_ID`

Replace `YOUR_CONTRACT_ID` with your actual contract ID.

## Alternative: Use the Batch Script

We've created `deploy.bat` for Windows. To use it:

1. Wait for Soroban CLI to finish installing
2. Add wasm32 target: `rustup target add wasm32-unknown-unknown`
3. Run the deployment script:

```cmd
cd soroban-contract
deploy.bat
```

The script will:
- Build the contract
- Optimize the WASM
- Configure testnet
- Create deployer identity (if needed)
- Prompt you to fund the account
- Deploy and initialize the contract
- Verify the deployment

## Troubleshooting

### "soroban not found"
- Soroban CLI is still installing. Wait a few more minutes
- Close and reopen your terminal after installation completes
- Add `%USERPROFILE%\.cargo\bin` to your PATH

### "error: target 'wasm32-unknown-unknown' not found"
Run: `rustup target add wasm32-unknown-unknown`

### "insufficient funds"
Your account needs lumens. Use friendbot (Step 7) to fund it.

### "contract already initialized"
Contracts can only be initialized once. Deploy a new contract if you need to change initialization data.

## Next Steps After Successful Deployment

1. Save your contract ID to a file: `CONTRACT_ID.txt`
2. Update the main README.md with your contract ID
3. Create a CONTRACT_INFO.md file with deployment details
4. Commit and push to GitHub:

```cmd
git add soroban-contract\ DEPLOYMENT_WINDOWS.md CONTRACT_ID.txt
git commit -m "Deploy smart contract to Stellar testnet"
git push origin main
```

5. Consider deploying to mainnet after thorough testing

## Costs

- **Testnet**: FREE! Use friendbot for test lumens
- **Mainnet**: ~5-10 XLM for deployment + ~1-2 XLM for initialization

## Support

- Soroban Documentation: https://soroban.stellar.org/docs
- Stellar Expert: https://stellar.expert/
- GitHub Repository: https://github.com/damianosakwe/stellar-java-sdk

---

**Once Soroban CLI installation completes, proceed with Step 2!** 🚀
