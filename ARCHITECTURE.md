# Stellar Java SDK - Architecture Overview

## Project Structure

```
stellar-java-sdk/
│
├── 📁 .github/workflows/          # CI/CD Automation
│   ├── test.yml                   # → Runs tests on every push/PR
│   ├── build.yml                  # → Builds artifacts + Android tests
│   ├── deploy.yml                 # → Publishes releases
│   └── codeql.yml                 # → Security scanning
│
├── 📁 src/
│   ├── 📁 main/java/org/stellar/sdk/
│   │   ├── 📄 *.java              # Core SDK classes
│   │   ├── 📁 operations/         # Stellar operations
│   │   ├── 📁 requests/           # Horizon API requests
│   │   ├── 📁 responses/          # Horizon API responses
│   │   ├── 📁 xdr/                # XDR type definitions
│   │   ├── 📁 contract/           # Soroban smart contracts
│   │   ├── 📁 scval/              # Soroban value types
│   │   ├── 📁 exception/          # Exception classes
│   │   └── 📁 federation/         # Federation protocol
│   │
│   ├── 📁 test/
│   │   ├── 📁 java/               # Java unit tests (~700)
│   │   ├── 📁 kotlin/             # Kotlin tests (~200)
│   │   └── 📁 resources/          # Test fixtures
│   │
├── 📁 examples/                   # Usage examples
│   └── src/main/java/
│       ├── Payment.java           # Simple payment
│       ├── QueryHorizon.java      # Query API
│       ├── SorobanCreateContract.java
│       ├── SorobanInvokeContractFunction.java
│       └── ... (8 examples total)
│
├── 📁 android_test/               # Android compatibility tests
│   └── app/
│       └── src/
│           ├── androidTest/       # Instrumented tests
│           └── main/              # Test app
│
├── 📁 xdr/                        # XDR protocol definitions
│   ├── Stellar-types.x
│   ├── Stellar-transaction.x
│   ├── Stellar-ledger.x
│   └── ... (13 XDR files)
│
├── 📁 xdr-generator/              # Code generator for XDR
│   ├── generate.rb
│   └── generator/
│
├── 📄 build.gradle.kts            # Build configuration
├── 📄 settings.gradle.kts         # Project settings
├── 📄 README.md                   # Main documentation
├── 📄 SETUP_GUIDE.md              # Deployment guide
├── 📄 QUICKSTART.md               # Quick start guide
├── 📄 CHANGELOG_v1.md             # Version history
└── 📄 LICENSE                     # Apache 2.0
```

## Component Architecture

### 1. Core SDK Layer
```
┌─────────────────────────────────────────┐
│         User Application                │
└──────────────┬──────────────────────────┘
               │
               ↓
┌─────────────────────────────────────────┐
│     Stellar Java SDK (Public API)       │
│  ┌──────────┐  ┌──────────┐            │
│  │KeyPair   │  │Account   │            │
│  │Asset     │  │Transaction│            │
│  └──────────┘  └──────────┘            │
│                                         │
│  ┌──────────────┐  ┌────────────────┐ │
│  │ Operations   │  │ Requests       │ │
│  │ - Payment    │  │ - Accounts     │ │
│  │ - PathPay    │  │ - Transactions │ │
│  │ - CreateAcc  │  │ - Effects      │ │
│  └──────────────┘  └────────────────┘ │
└──────────────┬──────────────────────────┘
               │
               ↓
┌─────────────────────────────────────────┐
│      Network Communication Layer        │
│  ┌──────────┐  ┌──────────┐            │
│  │ Server   │  │SorobanSrv│            │
│  │(Horizon) │  │ (RPC)    │            │
│  └──────────┘  └──────────┘            │
│        ↓              ↓                 │
│     OkHttp       OkHttp                 │
└──────────────┬──────────────────────────┘
               │
               ↓
┌─────────────────────────────────────────┐
│        Stellar Network                  │
│  ┌──────────────────────────────────┐  │
│  │  Horizon API  │  Soroban RPC     │  │
│  └──────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

### 2. Transaction Flow

```
User Code
    │
    ↓
┌─────────────────────┐
│ TransactionBuilder  │ ← Build transaction
└──────────┬──────────┘
           │
           ↓
┌─────────────────────┐
│  Add Operations     │ ← PaymentOp, CreateAccountOp, etc.
└──────────┬──────────┘
           │
           ↓
┌─────────────────────┐
│  Set Metadata       │ ← Timeout, fees, memo
└──────────┬──────────┘
           │
           ↓
┌─────────────────────┐
│  Build Transaction  │ ← Creates Transaction object
└──────────┬──────────┘
           │
           ↓
┌─────────────────────┐
│  Sign (KeyPair)     │ ← Add signatures
└──────────┬──────────┘
           │
           ↓
┌─────────────────────┐
│  XDR Serialization  │ ← Convert to XDR format
└──────────┬──────────┘
           │
           ↓
┌─────────────────────┐
│  Submit to Network  │ ← Server.submitTransaction()
└──────────┬──────────┘
           │
           ↓
   Stellar Network
```

### 3. CI/CD Pipeline

```
Developer Push
      │
      ↓
┌──────────────────────┐
│  GitHub Repository   │
└──────────┬───────────┘
           │
           ↓
┌──────────────────────┐
│   GitHub Actions     │
└──────────┬───────────┘
           │
           ├──→ test.yml ──────────┐
           │    ┌─────────────────┐│
           │    │ Setup JDK 21    ││
           │    │ Run Tests       ││
           │    │ Code Coverage   ││
           │    └─────────────────┘│
           │                       │
           ├──→ build.yml ─────────┤
           │    ┌─────────────────┐│
           │    │ Build JARs      ││
           │    │ Generate JavaDoc││
           │    │ Android Tests   ││
           │    └─────────────────┘│
           │                       │
           ├──→ codeql.yml ────────┤
           │    ┌─────────────────┐│
           │    │ Security Scan   ││
           │    └─────────────────┘│
           │                       │
           └──→ deploy.yml ────────┘
                ┌─────────────────┐
                │ GitHub Release  │
                │ Maven Central   │
                │ GitHub Pages    │
                └─────────────────┘
                       │
                       ↓
              Users Download
```

## Module Dependencies

```
Core SDK Dependencies:
├── OkHttp 4.12.0         # HTTP client + Server-Sent Events
│   └── Okio              # I/O library
├── Gson 2.14.0           # JSON serialization
├── Bouncy Castle 1.84    # Cryptography (Ed25519, SHA-256)
├── Commons Codec 1.22.0  # Base64, Hex encoding
└── TOML4J 0.7.2          # TOML parsing (for stellar.toml)

Test Dependencies:
├── JUnit 4.13.2          # Test framework
├── JUnit 5               # Modern test framework
├── Mockito 5.23.0        # Mocking framework
├── Kotest 6.1.11         # Kotlin testing
└── MockWebServer 4.12.0  # HTTP mocking

Build Tools:
├── Gradle 8.x            # Build automation
├── Spotless 8.7.0        # Code formatting
├── Lombok 9.5.0          # Boilerplate reduction
├── Jacoco                # Code coverage
└── NMCP 1.6.0            # Maven Central publishing
```

## Key Classes

### Account Management
```
KeyPair
  ├── fromSecretSeed()    # Load from secret key
  ├── random()            # Generate new keypair
  ├── fromAccountId()     # Public key only
  └── sign()              # Sign data

Account implements TransactionBuilderAccount
  ├── getAccountId()
  ├── getSequenceNumber()
  └── incrementSequenceNumber()
```

### Transaction Building
```
TransactionBuilder
  ├── addOperation()      # Add operations
  ├── setTimeout()        # Set timeout
  ├── setBaseFee()        # Set fee
  ├── setMemo()           # Add memo
  └── build()             # Create transaction

Transaction extends AbstractTransaction
  ├── sign()              # Sign transaction
  ├── toEnvelopeXdr()     # Convert to XDR
  └── hash()              # Get transaction hash
```

### Network Communication
```
Server
  ├── accounts()          # Account queries
  ├── transactions()      # Transaction queries
  ├── operations()        # Operation queries
  ├── payments()          # Payment queries
  ├── effects()           # Effect queries
  └── submitTransaction() # Submit transaction

SorobanServer
  ├── getNetwork()        # Network info
  ├── getLatestLedger()   # Latest ledger
  ├── simulateTransaction() # Simulate
  ├── sendTransaction()   # Submit
  └── getTransaction()    # Get status
```

## Data Flow Examples

### 1. Payment Flow
```
User
 │
 ├─→ Create KeyPair (source, destination)
 │
 ├─→ Connect to Horizon (Server)
 │
 ├─→ Load source account
 │
 ├─→ Build transaction
 │     └─→ Add PaymentOperation
 │     └─→ Set timeout, fees
 │
 ├─→ Sign transaction
 │
 ├─→ Submit to network
 │
 └─→ Receive confirmation
```

### 2. Smart Contract Invocation
```
User
 │
 ├─→ Connect to Soroban RPC
 │
 ├─→ Build InvokeHostFunction operation
 │     └─→ Contract address
 │     └─→ Function name
 │     └─→ Arguments (SCVal)
 │
 ├─→ Simulate transaction
 │     └─→ Get resource estimates
 │
 ├─→ Prepare transaction with simulation
 │
 ├─→ Sign and submit
 │
 └─→ Poll for result
```

## Package Organization

```
org.stellar.sdk/
├── [root]                    # Core classes (KeyPair, Account, etc.)
├── operations/               # All Stellar operations
├── requests/                 # Horizon API request builders
│   └── sorobanrpc/          # Soroban RPC requests
├── responses/                # Horizon API response models
│   ├── operations/          # Operation responses
│   ├── effects/             # Effect responses
│   ├── sorobanrpc/          # Soroban responses
│   └── gson/                # JSON deserializers
├── xdr/                      # XDR type definitions (generated)
├── contract/                 # Soroban contract utilities
│   └── exception/           # Contract exceptions
├── scval/                    # Soroban value types
├── exception/                # SDK exceptions
├── federation/               # Federation protocol
│   └── exception/           # Federation exceptions
└── spi/                      # Service Provider Interface
```

## Extension Points

### Custom Assets
```java
class MyAsset extends Asset {
    // Implement custom asset type
}
```

### Custom Operations
```java
class MyOperation extends Operation {
    // Implement custom operation
}
```

### Request Interceptors
```java
OkHttpClient client = new OkHttpClient.Builder()
    .addInterceptor(new MyInterceptor())
    .build();
    
Server server = new Server(url, client);
```

## Performance Considerations

### Connection Pooling
- OkHttp manages connection pooling automatically
- Reuse Server instances when possible
- Close connections when done

### Caching
- Implement response caching for read-heavy workloads
- Cache account data to reduce API calls
- Use streaming for real-time updates

### Async Operations
```java
// Use async callbacks
server.transactions()
    .forAccount(account)
    .cursor("now")
    .stream(new EventListener<>() {
        @Override
        public void onEvent(TransactionResponse tx) {
            // Handle asynchronously
        }
    });
```

## Security Architecture

### Key Management
- Private keys never leave the client
- Use secure key storage (Android Keystore, etc.)
- Never log or transmit private keys

### Transaction Signing
- All transactions must be signed before submission
- Multiple signatures supported (multi-sig)
- Signature verification on server side

### Network Selection
```java
// Testnet for development
Network.TESTNET

// Mainnet for production
Network.PUBLIC

// Custom network
new Network("Custom Network Passphrase")
```

## Testing Strategy

### Unit Tests (~700)
- Test individual classes and methods
- Mock external dependencies
- Fast execution (<1 minute)

### Integration Tests (~100)
- Test with real Stellar Quickstart
- Verify end-to-end flows
- Medium execution (~5 minutes)

### Android Tests (~20)
- Run on Android emulators
- Test API compatibility
- Slow execution (~15 minutes)

### Kotlin Tests (~200)
- Modern test patterns
- Property-based testing
- Type-safe assertions

## Deployment Architecture

```
Developer Machine
       │
       ├─→ git push
       │
       ↓
GitHub Repository
       │
       ├─→ GitHub Actions
       │
       ↓
   Test → Build → Deploy
       │
       ├─→ GitHub Releases (JARs)
       ├─→ GitHub Pages (JavaDoc)
       └─→ Maven Central (Published)
              │
              ↓
          End Users
```

---

For more details, see:
- [README.md](README.md) - General documentation
- [QUICKSTART.md](QUICKSTART.md) - Usage examples
- [SETUP_GUIDE.md](SETUP_GUIDE.md) - Deployment guide
