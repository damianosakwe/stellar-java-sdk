# Stellar Forge SDK - Soroban Smart Contract

This directory contains the Soroban smart contract that registers the Stellar Java SDK on the Stellar blockchain.

## Contract Overview

The `StellarForgeSDK` contract serves as an on-chain registry for the Stellar Java SDK project. It stores:

- **Project Metadata**: Name, version, organization, Maven coordinates
- **Repository Information**: GitHub URL
- **Statistics**: Total tests, version count, last update timestamp
- **Ownership**: Contract owner for version updates

## Contract Functions

### Initialize
```rust
fn initialize(
    env: Env,
    name: String,
    version: String,
    organization: String,
    group_id: String,
    artifact_id: String,
    repository: String,
    description: String,
    owner: Address
)
```
Initializes the contract with SDK information (can only be called once).

### Get SDK Info
```rust
fn get_sdk_info(env: Env) -> SDKInfo
```
Returns complete SDK information including name, version, organization, and Maven coordinates.

### Get Stats
```rust
fn get_stats(env: Env) -> Stats
```
Returns statistics including total tests (1228), version count, and last update timestamp.

### Update Version
```rust
fn update_version(env: Env, caller: Address, new_version: String)
```
Updates the SDK version (only owner can call). Increments version count and updates timestamp.

### Version
```rust
fn version(env: Env) -> String
```
Returns the current SDK version.

### Is Initialized
```rust
fn is_initialized(env: Env) -> bool
```
Checks if the contract has been initialized.

### Get Repository
```rust
fn get_repository(env: Env) -> String
```
Returns the GitHub repository URL.

### Get Maven Coordinates
```rust
fn get_maven_coordinates(env: Env) -> (String, String)
```
Returns Maven group ID and artifact ID as a tuple.

## Building the Contract

### Prerequisites
- Rust toolchain (install from https://rustup.rs/)
- Soroban CLI (`cargo install --locked soroban-cli`)
- wasm32 target (`rustup target add wasm32-unknown-unknown`)

### Build Commands

```bash
# Navigate to contract directory
cd soroban-contract

# Build the contract
cargo build --target wasm32-unknown-unknown --release

# Optimize the WASM (optional but recommended)
soroban contract optimize \
    --wasm target/wasm32-unknown-unknown/release/stellar_forge_sdk_contract.wasm
```

The optimized WASM will be in `target/wasm32-unknown-unknown/release/stellar_forge_sdk_contract.optimized.wasm`

## Testing the Contract

```bash
# Run unit tests
cargo test

# Run with output
cargo test -- --nocapture
```

## Deploying to Stellar

### 1. Set up Stellar CLI

```bash
# Configure for testnet
soroban config network add \
  --global testnet \
  --rpc-url https://soroban-testnet.stellar.org:443 \
  --network-passphrase "Test SDF Network ; September 2015"

# Generate identity (or use existing)
soroban keys generate deployer --network testnet

# Fund the account
soroban keys address deployer | xargs -I {} curl "https://friendbot.stellar.org?addr={}"
```

### 2. Deploy the Contract

```bash
# Deploy to testnet
CONTRACT_ID=$(soroban contract deploy \
  --wasm target/wasm32-unknown-unknown/release/stellar_forge_sdk_contract.optimized.wasm \
  --source deployer \
  --network testnet)

echo "Contract deployed at: $CONTRACT_ID"
```

### 3. Initialize the Contract

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

### 4. Query the Contract

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
```

## Deploying with Java SDK

See `../deployment/DeployContract.java` for a Java implementation that uses the Stellar Java SDK to deploy and interact with this contract.

## Contract Address

Once deployed, save your contract ID:
- **Testnet**: [Will be filled after deployment]
- **Mainnet**: [Deploy separately for production]

## Storage

The contract uses instance storage for:
- `SDK_INFO`: Complete SDK metadata
- `STATS`: Project statistics
- `OWNER`: Contract owner address

All data persists on-chain and is publicly readable.

## Security

- Only the contract owner can update the version
- Contract can only be initialized once
- All functions that modify state require authentication

## License

Apache License 2.0 - Same as the main SDK project
