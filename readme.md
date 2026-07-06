# Stellar Java SDK

[![Test and Build](https://github.com/stellarforge-io/stellar-java-sdk/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/stellarforge-io/stellar-java-sdk/actions/workflows/test.yml)
[![Maven Central Version](https://img.shields.io/maven-central/v/io.stellarforge/stellar-java-sdk)](https://central.sonatype.com/artifact/io.stellarforge/stellar-java-sdk)
[![javadoc](https://javadoc.io/badge2/io.stellarforge/stellar-java-sdk/javadoc.svg)](https://javadoc.io/doc/io.stellarforge/stellar-java-sdk)
[![codecov](https://codecov.io/gh/stellarforge-io/stellar-java-sdk/branch/main/graph/badge.svg)](https://codecov.io/gh/stellarforge-io/stellar-java-sdk)

A comprehensive Java SDK for building on the Stellar network. This library provides powerful APIs to build transactions and connect to [Horizon](https://developers.stellar.org/docs/data/apis/horizon) and [Soroban-RPC Server](https://soroban.stellar.org/docs/reference/rpc).

## Features

✨ **Complete Stellar API Coverage** - Full support for Horizon and Soroban-RPC
🔐 **Secure** - Built with security best practices
📱 **Android Compatible** - Works seamlessly on Android API 23+
🧪 **Well Tested** - Comprehensive test suite with high code coverage
📚 **Excellent Documentation** - Detailed JavaDoc and examples
🚀 **Modern Java** - Targets JDK 8+ bytecode, built with JDK 21

## Installation

### Apache Maven

```xml
<dependency>
    <groupId>io.stellarforge</groupId>
    <artifactId>stellar-java-sdk</artifactId>
    <version>1.0.0</version>
</dependency>
```

### Gradle

```groovy
implementation 'io.stellarforge:stellar-java-sdk:1.0.0'
```

### Kotlin DSL

```kotlin
implementation("io.stellarforge:stellar-java-sdk:1.0.0")
```

You can find instructions on how to install this dependency using alternative package managers on [Maven Central](https://central.sonatype.com/artifact/io.stellarforge/stellar-java-sdk).

### JAR

Download the latest JAR from the GitHub repo's [releases tab](https://github.com/stellarforge-io/stellar-java-sdk/releases). Add the `jar` package to your project according to how your environment is set up.

## Quick Start

Here's a simple example to get you started:

```java
import org.stellar.sdk.*;

// Create a new keypair
KeyPair source = KeyPair.random();
KeyPair destination = KeyPair.random();

// Connect to Horizon testnet
Server server = new Server("https://horizon-testnet.stellar.org");

// Load the source account
AccountResponse sourceAccount = server.accounts().account(source.getAccountId());

// Create a payment transaction
Transaction transaction = new TransactionBuilder(sourceAccount, Network.TESTNET)
    .addOperation(new PaymentOperation.Builder(
        destination.getAccountId(),
        new AssetTypeNative(),
        "10.00")
        .build())
    .setTimeout(180)
    .setBaseFee(Transaction.MIN_BASE_FEE)
    .build();

// Sign the transaction
transaction.sign(source);

// Submit to the network
SubmitTransactionResponse response = server.submitTransaction(transaction);
```

## Documentation

- **JavaDoc**: https://javadoc.io/doc/io.stellarforge/stellar-java-sdk
- **Examples**: Check out the [examples](./examples/src/main/java/) directory for comprehensive examples
- **Stellar Developers**: https://developers.stellar.org/

## Examples

This repository contains numerous helpful examples:

- [Payment Operations](./examples/src/main/java/Payment.java)
- [Query Horizon API](./examples/src/main/java/QueryHorizon.java)
- [Soroban Contract Creation](./examples/src/main/java/SorobanCreateContract.java)
- [Soroban Contract Invocation](./examples/src/main/java/SorobanInvokeContractFunction.java)
- [Upload WASM to Soroban](./examples/src/main/java/SorobanUploadWasm.java)
- [Asset Management](./examples/src/main/java/CheckStellarAssetContract.java)

## Android Integration

### API Level 28+

If you're integrating this SDK on Android platforms with API level 28 and above, you don't need any additional configuration.

### API Level < 28

For lower API levels, you may need to include the [Java Stellar SDK Android SPI](https://github.com/lightsail-network/java-stellar-sdk-android-spi).

## Building from Source

### Prerequisites

- JDK 21 (for building; the SDK targets JDK 8 bytecode)
- Gradle 8.x (included via Gradle Wrapper)

### Build

```bash
# Clone the repository
git clone https://github.com/stellarforge-io/stellar-java-sdk.git
cd stellar-java-sdk

# Build the project
./gradlew build

# Run tests
./gradlew test

# Generate JavaDoc
./gradlew javadoc
```

### Testing

The project includes comprehensive test coverage:

```bash
# Run all tests
./gradlew test

# Run tests with coverage report
./gradlew jacocoTestReport

# Run integration tests (requires Stellar Quickstart)
./gradlew check
```

## Project Structure

```
stellar-java-sdk/
├── src/
│   ├── main/java/org/stellar/sdk/     # Main SDK code
│   └── test/                           # Test suite (Java & Kotlin)
├── examples/                           # Usage examples
├── android_test/                       # Android compatibility tests
├── xdr/                                # XDR definitions
├── xdr-generator/                      # XDR code generator
├── build.gradle.kts                    # Build configuration
└── settings.gradle.kts                 # Project settings
```

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details on:

- Code of Conduct
- Development process
- Submitting pull requests
- Coding standards

### Development Setup

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests (`./gradlew test`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to your branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## CI/CD

This project uses GitHub Actions for continuous integration and deployment:

- **Test Workflow**: Runs on every PR and commit
- **Build Workflow**: Creates artifacts after tests pass
- **Deploy Workflow**: Publishes to Maven Central on release
- **Security Workflow**: CodeQL analysis and dependency scanning

## Versioning

We use [Semantic Versioning](https://semver.org/). For available versions, see the [releases page](https://github.com/stellarforge-io/stellar-java-sdk/releases).

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

This SDK is a fork based on the excellent work by the [Lightsail Network team](https://github.com/lightsail-network/java-stellar-sdk). We're grateful for their contributions to the Stellar ecosystem.

## Support

- 📖 **Documentation**: [JavaDoc](https://javadoc.io/doc/io.stellarforge/stellar-java-sdk)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/stellarforge-io/stellar-java-sdk/discussions)
- 🐛 **Issues**: [GitHub Issues](https://github.com/stellarforge-io/stellar-java-sdk/issues)
- 🌟 **Stellar Community**: [Stellar Developer Discord](https://discord.gg/stellardev)

## Roadmap

- [ ] Enhanced Soroban smart contract support
- [ ] Additional code examples and tutorials
- [ ] Performance optimizations
- [ ] Extended documentation
- [ ] Community-driven features

---

Made with ❤️ by the StellarForge team
