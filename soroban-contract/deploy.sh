#!/bin/bash

# Stellar Forge SDK - Contract Deployment Script
# This script builds and deploys the contract to Stellar Testnet

set -e

echo "=== Stellar Forge SDK - Contract Deployment ==="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if soroban is installed
if ! command -v soroban &> /dev/null; then
    echo "❌ Soroban CLI not found. Install it with:"
    echo "   cargo install --locked soroban-cli --features opt"
    exit 1
fi

echo -e "${BLUE}Step 1: Building contract...${NC}"
cargo build --target wasm32-unknown-unknown --release
echo -e "${GREEN}✓ Contract built${NC}"
echo ""

echo -e "${BLUE}Step 2: Optimizing WASM...${NC}"
soroban contract optimize \
    --wasm target/wasm32-unknown-unknown/release/stellar_forge_sdk_contract.wasm
echo -e "${GREEN}✓ WASM optimized${NC}"
echo ""

# Check if network is configured
if ! soroban config network ls | grep -q "testnet"; then
    echo -e "${BLUE}Step 3: Configuring testnet...${NC}"
    soroban config network add \
      --global testnet \
      --rpc-url https://soroban-testnet.stellar.org:443 \
      --network-passphrase "Test SDF Network ; September 2015"
    echo -e "${GREEN}✓ Testnet configured${NC}"
    echo ""
fi

# Check if deployer identity exists
if ! soroban keys ls | grep -q "deployer"; then
    echo -e "${YELLOW}⚠️  No 'deployer' identity found${NC}"
    echo "Creating new identity..."
    soroban keys generate deployer --network testnet
    echo ""
    echo -e "${YELLOW}⚠️  Please fund this account:${NC}"
    soroban keys address deployer
    echo ""
    echo "Visit: https://laboratory.stellar.org/#account-creator?network=test"
    echo "Or use friendbot:"
    echo "  curl \"https://friendbot.stellar.org?addr=\$(soroban keys address deployer)\""
    echo ""
    read -p "Press Enter after funding the account..."
fi

echo -e "${BLUE}Step 3: Deploying contract to testnet...${NC}"
CONTRACT_ID=$(soroban contract deploy \
  --wasm target/wasm32-unknown-unknown/release/stellar_forge_sdk_contract.optimized.wasm \
  --source deployer \
  --network testnet 2>&1 | tee /dev/tty | tail -n1)

echo -e "${GREEN}✓ Contract deployed!${NC}"
echo ""
echo -e "${GREEN}Contract ID: ${CONTRACT_ID}${NC}"
echo ""

# Save contract ID
echo "$CONTRACT_ID" > deployed_contract_id.txt
echo "Contract ID saved to: deployed_contract_id.txt"
echo ""

echo -e "${BLUE}Step 4: Initializing contract...${NC}"
OWNER=$(soroban keys address deployer)

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

echo -e "${GREEN}✓ Contract initialized!${NC}"
echo ""

echo -e "${BLUE}Step 5: Verifying deployment...${NC}"
echo ""

echo "SDK Info:"
soroban contract invoke \
  --id $CONTRACT_ID \
  --network testnet \
  -- \
  get_sdk_info

echo ""
echo "Statistics:"
soroban contract invoke \
  --id $CONTRACT_ID \
  --network testnet \
  -- \
  get_stats

echo ""
echo -e "${GREEN}=== Deployment Complete! ===${NC}"
echo ""
echo "Contract ID: $CONTRACT_ID"
echo "Network: Testnet"
echo "Owner: $OWNER"
echo ""
echo "View on Stellar Expert:"
echo "  https://stellar.expert/explorer/testnet/contract/$CONTRACT_ID"
echo ""
echo "Query contract:"
echo "  soroban contract invoke --id $CONTRACT_ID --network testnet -- get_sdk_info"
echo ""
echo "Update contract info in your repository:"
echo "  1. Update README.md with contract ID"
echo "  2. Create CONTRACT_INFO.md with deployment details"
echo "  3. Commit and push changes"
echo ""
