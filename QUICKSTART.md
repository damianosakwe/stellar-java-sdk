# Quick Start Guide - Stellar Java SDK

Get started with the Stellar Java SDK in under 5 minutes!

## Installation

### Maven

Add to your `pom.xml`:

```xml
<dependency>
    <groupId>io.stellarforge</groupId>
    <artifactId>stellar-java-sdk</artifactId>
    <version>1.0.0</version>
</dependency>
```

### Gradle

Add to your `build.gradle`:

```groovy
dependencies {
    implementation 'io.stellarforge:stellar-java-sdk:1.0.0'
}
```

Or with Kotlin DSL (`build.gradle.kts`):

```kotlin
dependencies {
    implementation("io.stellarforge:stellar-java-sdk:1.0.0")
}
```

## Your First Transaction

### 1. Create KeyPairs

```java
import org.stellar.sdk.*;

// Create a new random keypair
KeyPair source = KeyPair.random();
System.out.println("Source Public Key: " + source.getAccountId());
System.out.println("Source Secret: " + String.valueOf(source.getSecretSeed()));

// Or load from existing secret
KeyPair existing = KeyPair.fromSecretSeed("S...");
```

### 2. Connect to Network

```java
// Testnet
Server server = new Server("https://horizon-testnet.stellar.org");
Network network = Network.TESTNET;

// Mainnet (production)
// Server server = new Server("https://horizon.stellar.org");
// Network network = Network.PUBLIC;
```

### 3. Fund Account (Testnet Only)

```java
// Fund your account using Friendbot (testnet only)
String friendbotUrl = String.format(
    "https://friendbot.stellar.org?addr=%s",
    source.getAccountId()
);
new java.net.URL(friendbotUrl).openStream().close();
```

### 4. Load Account

```java
// Load the source account from Horizon
AccountResponse sourceAccount = server.accounts().account(source.getAccountId());
```

### 5. Build Transaction

```java
// Create destination keypair
KeyPair destination = KeyPair.random();

// Build a payment transaction
Transaction transaction = new TransactionBuilder(sourceAccount, network)
    .addOperation(
        new CreateAccountOperation.Builder(
            destination.getAccountId(),
            "10"  // Starting balance in XLM
        ).build()
    )
    .setTimeout(180)  // Transaction expires in 180 seconds
    .setBaseFee(Transaction.MIN_BASE_FEE)
    .build();
```

### 6. Sign and Submit

```java
// Sign the transaction
transaction.sign(source);

// Submit to the network
try {
    SubmitTransactionResponse response = server.submitTransaction(transaction);
    System.out.println("Success!");
    System.out.println("Transaction Hash: " + response.getHash());
} catch (Exception e) {
    System.err.println("Error: " + e.getMessage());
}
```

## Complete Example

```java
import org.stellar.sdk.*;
import org.stellar.sdk.responses.*;

public class StellarQuickStart {
    public static void main(String[] args) throws Exception {
        // 1. Create keypairs
        KeyPair source = KeyPair.random();
        KeyPair destination = KeyPair.random();
        
        System.out.println("Source: " + source.getAccountId());
        System.out.println("Destination: " + destination.getAccountId());
        
        // 2. Connect to testnet
        Server server = new Server("https://horizon-testnet.stellar.org");
        Network network = Network.TESTNET;
        
        // 3. Fund source account
        String friendbotUrl = String.format(
            "https://friendbot.stellar.org?addr=%s",
            source.getAccountId()
        );
        new java.net.URL(friendbotUrl).openStream().close();
        
        // Wait for account to be funded
        Thread.sleep(5000);
        
        // 4. Load account
        AccountResponse sourceAccount = server.accounts()
            .account(source.getAccountId());
        
        // 5. Build transaction
        Transaction transaction = new TransactionBuilder(sourceAccount, network)
            .addOperation(
                new CreateAccountOperation.Builder(
                    destination.getAccountId(),
                    "10"  // 10 XLM
                ).build()
            )
            .setTimeout(180)
            .setBaseFee(Transaction.MIN_BASE_FEE)
            .build();
        
        // 6. Sign
        transaction.sign(source);
        
        // 7. Submit
        SubmitTransactionResponse response = server.submitTransaction(transaction);
        
        System.out.println("Success!");
        System.out.println("Hash: " + response.getHash());
        System.out.println("Ledger: " + response.getLedger());
    }
}
```

## Common Operations

### Payment

```java
new PaymentOperation.Builder(
    destination.getAccountId(),
    new AssetTypeNative(),  // XLM
    "100"  // Amount
).build()
```

### Create Trust Line

```java
Asset asset = Asset.createNonNativeAsset("USD", issuer.getAccountId());

new ChangeTrustOperation.Builder(
    ChangeTrustAsset.create(asset),
    "1000"  // Trust limit
).build()
```

### Path Payment

```java
new PathPaymentStrictSendOperation.Builder(
    new AssetTypeNative(),  // Send asset
    "100",  // Send amount
    destination.getAccountId(),
    usdAsset,  // Destination asset
    "90"  // Minimum destination amount
).setPath(Arrays.asList(eurAsset))  // Optional path
.build()
```

### Manage Offer

```java
new ManageSellOfferOperation.Builder(
    assetToSell,
    assetToBuy,
    "100",  // Amount to sell
    "0.5"  // Price (buy/sell)
).build()
```

## Query Horizon

### Get Account

```java
AccountResponse account = server.accounts()
    .account(keypair.getAccountId());

System.out.println("Balances:");
for (AccountResponse.Balance balance : account.getBalances()) {
    System.out.println(balance.getAsset() + ": " + balance.getBalance());
}
```

### Get Transactions

```java
Page<TransactionResponse> transactions = server.transactions()
    .forAccount(account.getAccountId())
    .order(RequestBuilder.Order.DESC)
    .limit(10)
    .execute();

for (TransactionResponse tx : transactions.getRecords()) {
    System.out.println(tx.getHash());
}
```

### Stream Payments

```java
server.payments()
    .forAccount(account.getAccountId())
    .cursor("now")
    .stream(new EventListener<OperationResponse>() {
        @Override
        public void onEvent(OperationResponse payment) {
            if (payment instanceof PaymentOperationResponse) {
                PaymentOperationResponse p = (PaymentOperationResponse) payment;
                System.out.println("Received: " + p.getAmount() + " " + p.getAsset());
            }
        }
    });
```

## Soroban (Smart Contracts)

### Connect to Soroban RPC

```java
import org.stellar.sdk.SorobanServer;

SorobanServer soroban = new SorobanServer(
    "https://soroban-testnet.stellar.org"
);

// Get network info
GetNetworkResponse network = soroban.getNetwork();
System.out.println("Network: " + network.getNetworkPassphrase());
```

### Invoke Contract

```java
// Build contract invocation
Address contractAddress = new Address("C...");
String functionName = "transfer";

InvokeHostFunctionOperation operation = 
    InvokeHostFunctionOperation.invokeContractFunctionOperationBuilder(
        contractAddress,
        functionName,
        Arrays.asList(
            Scv.toAddress(from),
            Scv.toAddress(to),
            Scv.toInt128(amount)
        )
    ).build();

// Build and submit transaction
Transaction tx = new TransactionBuilder(account, network)
    .addOperation(operation)
    .setTimeout(180)
    .setBaseFee(100000)
    .build();

// Simulate first
SimulateTransactionResponse simulation = 
    soroban.simulateTransaction(tx);

// Prepare with simulation results
Transaction preparedTx = SorobanServer.prepareTransaction(
    tx,
    simulation
);

preparedTx.sign(source);
SendTransactionResponse response = soroban.sendTransaction(preparedTx);
```

## Error Handling

```java
try {
    SubmitTransactionResponse response = server.submitTransaction(transaction);
    
    if (!response.isSuccess()) {
        // Transaction failed
        System.err.println("Transaction failed!");
        System.err.println("Result code: " + response.getResultXdr());
    }
} catch (AccountNotFoundException e) {
    System.err.println("Account not found: " + e.getMessage());
} catch (BadRequestException e) {
    System.err.println("Bad request: " + e.getMessage());
} catch (IOException e) {
    System.err.println("Network error: " + e.getMessage());
}
```

## Best Practices

### 1. Use try-with-resources for Server

```java
try (Server server = new Server("https://horizon-testnet.stellar.org")) {
    // Your code
}
```

### 2. Set Appropriate Timeouts

```java
.setTimeout(180)  // 3 minutes - enough time but not too long
```

### 3. Check Account Exists

```java
try {
    AccountResponse account = server.accounts().account(address);
} catch (AccountNotFoundException e) {
    // Account doesn't exist yet
    System.out.println("Account needs to be created first");
}
```

### 4. Use Minimum Base Fee for Non-Urgent

```java
.setBaseFee(Transaction.MIN_BASE_FEE)  // 100 stroops
```

### 5. Store Keys Securely

```java
// NEVER commit secrets to version control
// Use environment variables or secure key stores
String secret = System.getenv("STELLAR_SECRET_KEY");
KeyPair keyPair = KeyPair.fromSecretSeed(secret);
```

## Resources

- **Full Documentation**: [README.md](README.md)
- **API Reference**: https://javadoc.io/doc/io.stellarforge/stellar-java-sdk
- **Examples**: [examples/](examples/src/main/java/)
- **Stellar Developers**: https://developers.stellar.org/
- **Community**: https://discord.gg/stellardev

## Common Issues

### Account Not Found
**Solution**: Fund the account first using Friendbot (testnet) or send XLM from an existing account.

### Transaction Failed
**Solution**: Check the result code in the response. Common issues:
- Insufficient balance
- Invalid destination
- Bad sequence number

### Network Timeout
**Solution**: Increase timeout or check network connectivity:
```java
OkHttpClient httpClient = new OkHttpClient.Builder()
    .connectTimeout(30, TimeUnit.SECONDS)
    .readTimeout(30, TimeUnit.SECONDS)
    .build();

Server server = new Server("https://horizon-testnet.stellar.org", httpClient);
```

## Next Steps

1. Read the [full README](README.md) for more details
2. Explore [examples](examples/src/main/java/) for advanced usage
3. Check the [API documentation](https://javadoc.io/doc/io.stellarforge/stellar-java-sdk)
4. Join the [Stellar Developer Discord](https://discord.gg/stellardev)

---

**Happy Building on Stellar! 🚀**
