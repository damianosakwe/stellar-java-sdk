package deployment;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import org.stellar.sdk.*;
import org.stellar.sdk.operations.InvokeHostFunctionOperation;
import org.stellar.sdk.scval.Scv;
import org.stellar.sdk.xdr.*;

/**
 * Deploy the Stellar Forge SDK contract to Stellar Testnet
 * 
 * This script demonstrates how to:
 * 1. Deploy a Soroban smart contract using the Java SDK
 * 2. Initialize the contract with SDK metadata
 * 3. Query the contract to verify deployment
 */
public class DeployContract {
    
    private static final String TESTNET_RPC_URL = "https://soroban-testnet.stellar.org:443";
    private static final String TESTNET_NETWORK_PASSPHRASE = Network.TESTNET.getNetworkPassphrase();
    
    private final SorobanServer sorobanServer;
    private final Server horizonServer;
    private final KeyPair deployerKeypair;
    
    public DeployContract(String secretKey) {
        this.sorobanServer = new SorobanServer(TESTNET_RPC_URL);
        this.horizonServer = new Server("https://horizon-testnet.stellar.org");
        this.deployerKeypair = KeyPair.fromSecretSeed(secretKey);
    }
    
    /**
     * Step 1: Upload the contract WASM
     */
    public String uploadContractWasm(byte[] wasmBytes) throws IOException {
        System.out.println("Uploading contract WASM...");
        
        // Get the account
        AccountResponse account = horizonServer.accounts().account(deployerKeypair.getAccountId());
        
        // Create upload contract operation
        InvokeHostFunctionOperation uploadOp = InvokeHostFunctionOperation.uploadContractWasmBuilder(wasmBytes).build();
        
        // Build and sign transaction
        Transaction transaction = new TransactionBuilder(account, Network.TESTNET)
            .addOperation(uploadOp)
            .setTimeout(180)
            .setBaseFee(50000)
            .build();
        
        transaction.sign(deployerKeypair);
        
        // Simulate to get footprint
        SimulateTransactionResponse simulateResponse = sorobanServer.simulateTransaction(transaction);
        
        if (simulateResponse.getError() != null) {
            throw new RuntimeException("Simulation failed: " + simulateResponse.getError());
        }
        
        // Prepare and send transaction
        Transaction preparedTransaction = sorobanServer.prepareTransaction(transaction, simulateResponse);
        preparedTransaction.sign(deployerKeypair);
        
        SendTransactionResponse sendResponse = sorobanServer.sendTransaction(preparedTransaction);
        
        // Wait for transaction
        GetTransactionResponse txResponse = waitForTransaction(sendResponse.getHash());
        
        if (txResponse.getStatus() != GetTransactionResponse.GetTransactionStatus.SUCCESS) {
            throw new RuntimeException("Upload failed: " + txResponse.getStatus());
        }
        
        // Extract WASM hash from result
        String wasmHash = extractWasmHash(txResponse);
        
        System.out.println("✓ WASM uploaded successfully");
        System.out.println("  WASM Hash: " + wasmHash);
        
        return wasmHash;
    }
    
    /**
     * Step 2: Deploy the contract
     */
    public String deployContract(String wasmHash) throws IOException {
        System.out.println("Deploying contract...");
        
        // Get the account
        AccountResponse account = horizonServer.accounts().account(deployerKeypair.getAccountId());
        
        // Create deploy contract operation
        byte[] wasmHashBytes = Util.hexToBytes(wasmHash);
        Address deployerAddress = new Address(deployerKeypair.getAccountId());
        
        InvokeHostFunctionOperation deployOp = InvokeHostFunctionOperation
            .createContractBuilder(deployerAddress, wasmHashBytes, Util.hexToBytes(""))
            .build();
        
        // Build and sign transaction
        Transaction transaction = new TransactionBuilder(account, Network.TESTNET)
            .addOperation(deployOp)
            .setTimeout(180)
            .setBaseFee(100000)
            .build();
        
        transaction.sign(deployerKeypair);
        
        // Simulate to get footprint
        SimulateTransactionResponse simulateResponse = sorobanServer.simulateTransaction(transaction);
        
        if (simulateResponse.getError() != null) {
            throw new RuntimeException("Simulation failed: " + simulateResponse.getError());
        }
        
        // Prepare and send transaction
        Transaction preparedTransaction = sorobanServer.prepareTransaction(transaction, simulateResponse);
        preparedTransaction.sign(deployerKeypair);
        
        SendTransactionResponse sendResponse = sorobanServer.sendTransaction(preparedTransaction);
        
        // Wait for transaction
        GetTransactionResponse txResponse = waitForTransaction(sendResponse.getHash());
        
        if (txResponse.getStatus() != GetTransactionResponse.GetTransactionStatus.SUCCESS) {
            throw new RuntimeException("Deployment failed: " + txResponse.getStatus());
        }
        
        // Extract contract ID from result
        String contractId = extractContractId(txResponse);
        
        System.out.println("✓ Contract deployed successfully");
        System.out.println("  Contract ID: " + contractId);
        
        return contractId;
    }
    
    /**
     * Step 3: Initialize the contract
     */
    public void initializeContract(String contractId) throws IOException {
        System.out.println("Initializing contract...");
        
        // Get the account
        AccountResponse account = horizonServer.accounts().account(deployerKeypair.getAccountId());
        
        // Prepare function parameters
        Address ownerAddress = new Address(deployerKeypair.getAccountId());
        
        SCVal[] params = new SCVal[] {
            Scv.toString("Stellar Java SDK"),           // name
            Scv.toString("1.0.0"),                       // version
            Scv.toString("StellarForge"),                // organization
            Scv.toString("io.stellarforge"),             // group_id
            Scv.toString("stellar-java-sdk"),            // artifact_id
            Scv.toString("https://github.com/damianosakwe/stellar-java-sdk"), // repository
            Scv.toString("Comprehensive Java SDK for building on the Stellar network"), // description
            ownerAddress.toSCVal()                        // owner
        };
        
        // Create invoke operation
        InvokeHostFunctionOperation invokeOp = InvokeHostFunctionOperation
            .invokeContractFunctionBuilder(contractId, "initialize", params)
            .build();
        
        // Build and sign transaction
        Transaction transaction = new TransactionBuilder(account, Network.TESTNET)
            .addOperation(invokeOp)
            .setTimeout(180)
            .setBaseFee(100000)
            .build();
        
        transaction.sign(deployerKeypair);
        
        // Simulate to get footprint and auth
        SimulateTransactionResponse simulateResponse = sorobanServer.simulateTransaction(transaction);
        
        if (simulateResponse.getError() != null) {
            throw new RuntimeException("Simulation failed: " + simulateResponse.getError());
        }
        
        // Prepare and send transaction
        Transaction preparedTransaction = sorobanServer.prepareTransaction(transaction, simulateResponse);
        preparedTransaction.sign(deployerKeypair);
        
        SendTransactionResponse sendResponse = sorobanServer.sendTransaction(preparedTransaction);
        
        // Wait for transaction
        GetTransactionResponse txResponse = waitForTransaction(sendResponse.getHash());
        
        if (txResponse.getStatus() != GetTransactionResponse.GetTransactionStatus.SUCCESS) {
            throw new RuntimeException("Initialization failed: " + txResponse.getStatus());
        }
        
        System.out.println("✓ Contract initialized successfully");
    }
    
    /**
     * Query: Get SDK info from contract
     */
    public void querySdkInfo(String contractId) throws IOException {
        System.out.println("\nQuerying SDK info...");
        
        // Get the account
        AccountResponse account = horizonServer.accounts().account(deployerKeypair.getAccountId());
        
        // Create invoke operation
        InvokeHostFunctionOperation invokeOp = InvokeHostFunctionOperation
            .invokeContractFunctionBuilder(contractId, "get_sdk_info", new SCVal[]{})
            .build();
        
        // Build transaction
        Transaction transaction = new TransactionBuilder(account, Network.TESTNET)
            .addOperation(invokeOp)
            .setTimeout(180)
            .setBaseFee(50000)
            .build();
        
        transaction.sign(deployerKeypair);
        
        // Simulate
        SimulateTransactionResponse simulateResponse = sorobanServer.simulateTransaction(transaction);
        
        if (simulateResponse.getError() != null) {
            throw new RuntimeException("Query failed: " + simulateResponse.getError());
        }
        
        // Parse and display result
        System.out.println("✓ SDK Info retrieved:");
        System.out.println("  Result: " + simulateResponse.getResults());
    }
    
    /**
     * Wait for transaction to be confirmed
     */
    private GetTransactionResponse waitForTransaction(String txHash) throws IOException {
        System.out.println("  Waiting for confirmation...");
        
        for (int i = 0; i < 60; i++) {
            try {
                Thread.sleep(2000);
            } catch (InterruptedException e) {
                throw new RuntimeException(e);
            }
            
            GetTransactionResponse response = sorobanServer.getTransaction(txHash);
            
            if (response.getStatus() != GetTransactionResponse.GetTransactionStatus.NOT_FOUND) {
                return response;
            }
            
            System.out.print(".");
        }
        
        throw new RuntimeException("Transaction timeout");
    }
    
    /**
     * Extract WASM hash from transaction result
     */
    private String extractWasmHash(GetTransactionResponse response) {
        // Implementation depends on XDR parsing
        // This is a placeholder - actual implementation would parse the XDR result
        return "WASM_HASH_PLACEHOLDER";
    }
    
    /**
     * Extract contract ID from transaction result
     */
    private String extractContractId(GetTransactionResponse response) {
        // Implementation depends on XDR parsing
        // This is a placeholder - actual implementation would parse the XDR result
        return "CONTRACT_ID_PLACEHOLDER";
    }
    
    /**
     * Main deployment script
     */
    public static void main(String[] args) {
        if (args.length < 2) {
            System.out.println("Usage: java DeployContract <secret_key> <wasm_file_path>");
            System.out.println("\nExample:");
            System.out.println("  java DeployContract SXXX... /path/to/contract.wasm");
            System.out.println("\nTo generate a new keypair:");
            System.out.println("  KeyPair kp = KeyPair.random();");
            System.out.println("  System.out.println(\"Secret: \" + new String(kp.getSecretSeed()));");
            System.out.println("  System.out.println(\"Public: \" + kp.getAccountId());");
            System.out.println("\nFund the account at: https://laboratory.stellar.org/#account-creator?network=test");
            return;
        }
        
        String secretKey = args[0];
        String wasmFilePath = args[1];
        
        try {
            // Load WASM file
            byte[] wasmBytes = Files.readAllBytes(Paths.get(wasmFilePath));
            System.out.println("Loaded WASM file: " + wasmBytes.length + " bytes\n");
            
            // Create deployer
            DeployContract deployer = new DeployContract(secretKey);
            
            // Execute deployment
            System.out.println("=== Stellar Forge SDK - Contract Deployment ===\n");
            
            String wasmHash = deployer.uploadContractWasm(wasmBytes);
            String contractId = deployer.deployContract(wasmHash);
            deployer.initializeContract(contractId);
            deployer.querySdkInfo(contractId);
            
            System.out.println("\n=== Deployment Complete! ===");
            System.out.println("Contract ID: " + contractId);
            System.out.println("\nSave this contract ID - it's your SDK's on-chain address!");
            System.out.println("View on Stellar Expert: https://stellar.expert/explorer/testnet/contract/" + contractId);
            
        } catch (Exception e) {
            System.err.println("Deployment failed: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }
}
