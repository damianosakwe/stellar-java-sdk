# 🚀 Deploying Stellar Java SDK to Stellar Blockchain

This guide explains how to deploy the Stellar Forge SDK smart contract to the Stellar blockchain using Soroban.

## What Gets Deployed

A **Soroban smart contract** that serves as an on-chain registry for your SDK project, storing:
- SDK metadata (name, version, organization)
- Maven coordinates (group ID, artifact ID)
- Repository information
- Project statistics (1228 tests, version count)
- Update history

## Prerequisites

### 1. Install Rust and Soroban CLI

```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

# Add wasm32 target
rustup target add wasm32-unknown-unknown

# Install Soroban CLI
cargo install --locked soroban-cli --features opt

# Verify installation
soroban --version
```

### 2. Set Up Stellar Account

```bash
# Create a new identity
soroban keys generate deployer --network testnet

# Get your address
soroban keys address deployer

# Fund the account (copy the address and visit):
# https://laboratory.stellar.org/#account-creator?network=test
# Or use friendbot:
curl "https://friendbot.stellar.org?addr=$(soroban keys address deployer)"
```

## Deployment Steps

### Method 1: Using Soroban CLI (Recommended)

#### Step 1: Build the Contract

```bash
cd soroban-contract

# Build the contract
cargo build --target wasm32-unknown-unknown --release

# Optimize the WASM
soroban contract optimize \
    --wasm target/wasm32-unknown-unknown/release/stellar_forge_sdk_contract.wasm
```

#### Step 2: Configure Network

```bash
# Add testnet network
soroban config network add \
  --global testnet \
  --rpc-url https://soroban-testnet.stellar.org:443 \
  --network-passphrase "Test SDF Network ; September 2015"
```

#### Step 3: Deploy to Testnet

```bash
# Deploy the contract
CONTRACT_ID=$(soroban contract deploy \
  --wasm target/wasm32-unknown-unknown/release/stellar_forge_sdk_contract.optimized.wasm \
  --source deployer \
  --network testnet)

echo "Contract deployed at: $CONTRACT_ID"

# Save contract ID
echo $CONTRACT_ID > deployed_contract_id.txt
```

#### Step 4: Initialize the Contract

```bash
# Get your address
OWNER=$(soroban keys address deployer)

# Initialize with SDK information
soroban contract invoke \
  --id $CONTRACT_ID \
  --source deployer \
  --network testnet \
  -- \
  initialize \
  --name "Stellar Java SDK" \
  --version "1.0.0" \
  --organization "StellarForge" \
  --group_id "io.stellarforge" \
  --artifact_id "stellar-java-sdk" \
  --repository "https://github.com/damianosakwe/stellar-java-sdk" \
  --description "Comprehensive Java SDK for building on the Stellar network" \
  --owner "$OWNER"
```

#### Step 5: Verify Deployment

```bash
# Get SDK info
soroban contract invoke \
  --id $CONTRACT_ID \
  --network testnet \
  -- \
  get_sdk_info

# Get statistics
soroban contract invoke \
  --id $CONTRACT_ID \
  --network testnet \
  -- \
  get_stats

# Get version
soroban contract invoke \
  --id $CONTRACT_ID \
  --network testnet \
  -- \
  version

# Get repository
soroban contract invoke \
  --id $CONTRACT_ID \
  --network testnet \
  -- \
  get_repository

# Get Maven coordinates
soroban contract invoke \
  --id $CONTRACT_ID \
  --network testnet \
  -- \
  get_maven_coordinates
```

### Method 2: Using Java SDK

#### Prerequisites
- Java 21 installed
- Stellar Java SDK built

#### Compile and Run Deployer

```bash
# Navigate to project root
cd ..

# Compile the deployer
javac -cp "build/libs/*:." deployment/DeployContract.java

# Run deployment
java -cp "build/libs/*:." deployment.DeployContract \
  YOUR_SECRET_KEY \
  soroban-contract/target/wasm32-unknown-unknown/release/stellar_forge_sdk_contract.optimized.wasm
```

Replace `YOUR_SECRET_KEY` with your Stellar secret key (starts with `S`).

## After Deployment

### 1. Save Contract Information

Create a file `CONTRACT_INFO.md` with:

```markdown
# Stellar Forge SDK - On-Chain Contract

- **Contract ID**: [Your contract ID]
- **Network**: Testnet
- **Deployed**: [Date]
- **Owner**: [Your public key]

## Links
- Stellar Expert: https://stellar.expert/explorer/testnet/contract/[CONTRACT_ID]
- Testnet RPC: https://soroban-testnet.stellar.org:443
```

### 2. Update README

Add to your main README.md:

```markdown
## On-Chain Registry

This SDK is registered on the Stellar blockchain via a Soroban smart contract:

- **Contract ID**: `[Your contract ID]`
- **Network**: Testnet
- **View on Explorer**: https://stellar.expert/explorer/testnet/contract/[CONTRACT_ID]

Query the contract to get SDK metadata:
\`\`\`bash
soroban contract invoke --id [CONTRACT_ID] --network testnet -- get_sdk_info
\`\`\`
```

### 3. Commit to Repository

```bash
git add soroban-contract/ deployment/ SOROBAN_DEPLOYMENT.md CONTRACT_INFO.md
git commit -m "Add Soroban smart contract and deployment scripts"
git push origin main
```

## Deploying to Mainnet

**⚠️ Important**: Test thoroughly on testnet first!

### 1. Configure Mainnet

```bash
soroban config network add \
  --global mainnet \
  --rpc-url https://soroban-mainnet.stellar.org:443 \
  --network-passphrase "Public Global Stellar Network ; September 2015"

# Create mainnet identity
soroban keys generate mainnet-deployer --network mainnet

# Fund with real XLM (minimum ~5 XLM for contract deployment)
```

### 2. Deploy to Mainnet

```bash
# Build contract (same as testnet)
cd soroban-contract
cargo build --target wasm32-unknown-unknown --release
soroban contract optimize \
    --wasm target/wasm32-unknown-unknown/release/stellar_forge_sdk_contract.wasm

# Deploy
CONTRACT_ID=$(soroban contract deploy \
  --wasm target/wasm32-unknown-unknown/release/stellar_forge_sdk_contract.optimized.wasm \
  --source mainnet-deployer \
  --network mainnet)

echo "Mainnet Contract ID: $CONTRACT_ID"

# Initialize (same as testnet, but use mainnet network)
OWNER=$(soroban keys address mainnet-deployer)

soroban contract invoke \
  --id $CONTRACT_ID \
  --source mainnet-deployer \
  --network mainnet \
  -- \
  initialize \
  --name "Stellar Java SDK" \
  --version "1.0.0" \
  --organization "StellarForge" \
  --group_id "io.stellarforge" \
  --artifact_id "stellar-java-sdk" \
  --repository "https://github.com/damianosakwe/stellar-java-sdk" \
  --description "Comprehensive Java SDK for building on the Stellar network" \
  --owner "$OWNER"
```

## Contract Functions

### Read-Only Functions (No cost)

```bash
# Get SDK information
soroban contract invoke --id $CONTRACT_ID --network testnet -- get_sdk_info

# Get statistics
soroban contract invoke --id $CONTRACT_ID --network testnet -- get_stats

# Get version
soroban contract invoke --id $CONTRACT_ID --network testnet -- version

# Check if initialized
soroban contract invoke --id $CONTRACT_ID --network testnet -- is_initialized

# Get repository URL
soroban contract invoke --id $CONTRACT_ID --network testnet -- get_repository

# Get Maven coordinates
soroban contract invoke --id $CONTRACT_ID --network testnet -- get_maven_coordinates
```

### Write Functions (Requires authentication and fees)

```bash
# Update version (only owner can call)
soroban contract invoke \
  --id $CONTRACT_ID \
  --source deployer \
  --network testnet \
  -- \
  update_version \
  --caller "$(soroban keys address deployer)" \
  --new_version "1.1.0"
```

## Costs

### Testnet
- Free! Use friendbot for XLM
- Deployment: ~0.5 XLM
- Initialization: ~0.1 XLM
- Queries: Free (read-only)

### Mainnet
- Deployment: ~5-10 XLM
- Initialization: ~1-2 XLM
- Each transaction: ~0.00001 XLM + fees
- Queries: Free (read-only)

## Troubleshooting

### Error: "Contract already initialized"
- Contract can only be initialized once
- Deploy a new contract if you need to change initialization data

### Error: "Only owner can update version"
- Make sure you're calling with the same key that initialized the contract
- Use `--source` flag with correct identity

### Error: "Insufficient funds"
- Check balance: `soroban keys address deployer | xargs -I {} stellar account --network testnet get {}`
- Fund account: https://laboratory.stellar.org/#account-creator?network=test

### Error: "Simulation failed"
- Check RPC URL is correct
- Verify network passphrase matches
- Try again (sometimes RPC has temporary issues)

## Monitoring

### View Contract on Explorer
- Testnet: https://stellar.expert/explorer/testnet/contract/[CONTRACT_ID]
- Mainnet: https://stellar.expert/explorer/public/contract/[CONTRACT_ID]

### Check Contract State
```bash
# View all contract data
soroban contract read \
  --id $CONTRACT_ID \
  --network testnet
```

## Security

- ✅ Contract can only be initialized once
- ✅ Only owner can update version
- ✅ All write operations require authentication
- ✅ Data persists on-chain indefinitely
- ✅ Read operations are always public

## Next Steps

1. ✅ Deploy contract to testnet
2. ✅ Test all functions
3. ✅ Verify on Stellar Expert
4. ✅ Update documentation with contract ID
5. ✅ Consider mainnet deployment
6. 📱 Integrate contract queries into SDK documentation
7. 🔄 Set up version update automation

## Resources

- Soroban Docs: https://soroban.stellar.org/docs
- Stellar Expert: https://stellar.expert/
- Soroban CLI: https://soroban.stellar.org/docs/reference/soroban-cli
- Your SDK Repo: https://github.com/damianosakwe/stellar-java-sdk

---

**Ready to deploy? Start with testnet first!** 🚀
