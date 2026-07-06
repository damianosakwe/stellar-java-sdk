# Changelog - Stellar Java SDK

All notable changes to this fork will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-07-06

### Project Fork
This is the initial release of the Stellar Java SDK fork by StellarForge.

### Changed
- **Organization**: Changed from `lightsail-network` to `stellarforge-io`
- **Maven Coordinates**: 
  - Group ID: `network.lightsail` → `io.stellarforge`
  - Artifact ID: `stellar-sdk` → `stellar-java-sdk`
  - Version: Started at `1.0.0`
- **Repository**: Renamed to `stellar-java-sdk`
- **Documentation**: Completely rewritten README with StellarForge branding
- **CI/CD**: Redesigned GitHub Actions workflows for better organization:
  - Separated test, build, and deploy workflows
  - Enhanced security with CodeQL integration
  - Improved caching and performance
  - Better artifact management

### Added
- New comprehensive README with:
  - Enhanced feature list
  - Quick start guide
  - Better examples
  - Roadmap section
- SETUP_GUIDE.md with detailed deployment instructions
- Improved CI/CD workflows:
  - `test.yml` - Dedicated testing workflow
  - `build.yml` - Artifact building and Android testing
  - `deploy.yml` - Release deployment to Maven Central and GitHub
  - `codeql.yml` - Security analysis
- Gradle caching in all workflows for faster builds
- Better test result archival
- Enhanced error handling in deployment

### Maintained
- ✅ All original functionality from java-stellar-sdk v4.0.0
- ✅ Complete test suite (Java + Kotlin)
- ✅ Android compatibility (API 23+)
- ✅ Full Stellar API support (Horizon + Soroban)
- ✅ Comprehensive XDR implementation
- ✅ All examples and documentation
- ✅ Apache 2.0 License

### Infrastructure
- JDK 21 for building (targets JDK 8 bytecode)
- Gradle 8.x with Kotlin DSL
- JUnit 5 + Kotest for testing
- Jacoco for code coverage
- Spotless for code formatting
- Lombok for reducing boilerplate

### Dependencies (Maintained from Original)
- OkHttp 4.12.0
- Gson 2.14.0
- Bouncy Castle 1.84
- Commons Codec 1.22.0
- TOML4J 0.7.2

### Testing
- Comprehensive unit tests
- Integration tests with Stellar Quickstart
- Android instrumentation tests (API 23, 34)
- Code coverage reporting
- Kotlin test support

### Security
- CodeQL security analysis
- Dependency scanning
- GPG signing for releases
- Secure secrets management

## Differences from Original (java-stellar-sdk v4.0.0)

### Configuration
- Different Maven coordinates for independent versioning
- Updated URLs and branding
- Reorganized CI/CD workflows

### Maintained Compatibility
- Same public API surface
- Same package structure (`org.stellar.sdk`)
- Compatible with all existing code
- No breaking changes

## Migration from Original SDK

If migrating from `network.lightsail:stellar-sdk`:

### Maven
```xml
<!-- Old -->
<dependency>
    <groupId>network.lightsail</groupId>
    <artifactId>stellar-sdk</artifactId>
    <version>4.0.0</version>
</dependency>

<!-- New -->
<dependency>
    <groupId>io.stellarforge</groupId>
    <artifactId>stellar-java-sdk</artifactId>
    <version>1.0.0</version>
</dependency>
```

### Gradle
```groovy
// Old
implementation 'network.lightsail:stellar-sdk:4.0.0'

// New
implementation 'io.stellarforge:stellar-java-sdk:1.0.0'
```

**No code changes required!** The package names remain the same (`org.stellar.sdk`).

## Acknowledgments

This project is based on the excellent work by:
- [Lightsail Network team](https://github.com/lightsail-network/java-stellar-sdk)
- Original contributors to java-stellar-sdk
- The Stellar Development Foundation

We maintain compatibility with the original while providing independent updates and improvements.

## Future Plans

See [README.md](README.md#roadmap) for the project roadmap.

---

For the original project's changelog, see the [upstream repository](https://github.com/lightsail-network/java-stellar-sdk/blob/master/CHANGELOG.md).
