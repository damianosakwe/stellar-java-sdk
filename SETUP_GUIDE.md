# Stellar Java SDK - Setup Guide

This guide will help you set up and deploy the Stellar Java SDK to your own organization.

## Project Information

- **Organization**: stellarforge-io
- **Repository**: stellar-java-sdk
- **Maven Group ID**: io.stellarforge
- **Maven Artifact ID**: stellar-java-sdk
- **Version**: 1.0.0

## What's Been Done

### 1. Project Configuration Updated ✅

- Updated `build.gradle.kts` with new Maven coordinates
- Changed group from `network.lightsail` to `io.stellarforge`
- Changed artifact ID from `stellar-sdk` to `stellar-java-sdk`
- Updated version to `1.0.0`
- Updated all POM metadata (URLs, developers, organization)
- Updated import order in Spotless configuration

### 2. Repository Renamed ✅

- Changed root project name from `stellar-sdk` to `stellar-java-sdk` in `settings.gradle.kts`

### 3. Documentation Updated ✅

- Created new `README.md` with updated:
  - Maven coordinates
  - Installation instructions
  - GitHub URLs
  - Organization branding
  - Feature list
  - Examples
  - Contributing guidelines

### 4. CI/CD Workflows Created ✅

Created four optimized GitHub Actions workflows:

#### `test.yml` - Continuous Testing
- Runs on every push to `main`/`develop` and PRs
- Sets up Stellar Quickstart service
- Executes full test suite
- Uploads coverage to Codecov
- Runs weekly on Monday at 00:30 UTC

#### `build.yml` - Build Artifacts
- Builds JARs (main, uber, sources, javadoc)
- Generates JavaDoc documentation
- Runs Android compatibility tests (API 23 and 34)
- Archives all artifacts

#### `deploy.yml` - Release Deployment
- Triggers on GitHub releases
- Publishes artifacts to GitHub Releases
- Deploys JavaDoc to GitHub Pages
- Publishes to Maven Central
- Validates signing configuration

#### `codeql.yml` - Security Analysis
- CodeQL security scanning
- Runs on push, PR, and weekly schedule
- Extended security queries

## Next Steps

### 1. Create GitHub Repository

```bash
# In the stellar-java-sdk directory
git init
git add .
git commit -m "Initial commit: Stellar Java SDK v1.0.0"

# Create repository on GitHub as stellarforge-io/stellar-java-sdk
# Then push
git branch -M main
git remote add origin https://github.com/stellarforge-io/stellar-java-sdk.git
git push -u origin main
```

### 2. Configure GitHub Repository Settings

#### Enable GitHub Pages
1. Go to Settings → Pages
2. Set source to `gh-pages` branch
3. This will host JavaDoc at `https://stellarforge-io.github.io/stellar-java-sdk/`

#### Add Repository Secrets
Go to Settings → Secrets and variables → Actions, and add:

- `CODECOV_TOKEN`: Get from https://codecov.io
- `SONATYPE_USERNAME`: Your Sonatype account username
- `SONATYPE_PASSWORD`: Your Sonatype account password
- `SIGNING_KEY_ID`: Your GPG key ID
- `SIGNING_KEY`: Your GPG private key (ASCII armored)
  ```bash
  # Export your key
  gpg2 --export-secret-keys --armor {KEY_ID} | grep -v '\-\-' | grep -v '^=.' | tr -d '\n'
  ```
- `SIGNING_PASSWORD`: Your GPG key password

### 3. Set Up Maven Central Publishing

1. **Create Sonatype Account**
   - Register at https://central.sonatype.com/
   - Verify your namespace (io.stellarforge)

2. **Generate GPG Keys**
   ```bash
   # Generate a new key
   gpg --full-generate-key
   
   # List keys
   gpg --list-secret-keys --keyid-format=long
   
   # Export public key
   gpg --armor --export {KEY_ID}
   
   # Upload to keyserver
   gpg --keyserver keyserver.ubuntu.com --send-keys {KEY_ID}
   ```

3. **Configure Gradle Signing**
   The `build.gradle.kts` is already configured to use environment variables for signing.

### 4. Verify Build Locally

```bash
cd stellar-java-sdk

# Run tests
./gradlew test

# Build all artifacts
./gradlew build

# Generate JavaDoc
./gradlew javadoc

# Check code coverage
./gradlew jacocoTestReport
```

### 5. Create Your First Release

1. Update version in `build.gradle.kts` if needed
2. Commit and push all changes
3. Create a git tag:
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```
4. Create a GitHub Release from the tag
5. CI/CD will automatically:
   - Run all tests
   - Build artifacts
   - Publish to Maven Central
   - Deploy JavaDoc to GitHub Pages

## Testing the CI/CD Pipeline

### 1. Test Workflow
Create a pull request and verify:
- ✅ Tests pass
- ✅ Coverage report is uploaded
- ✅ Build succeeds

### 2. Build Workflow
After merging to main:
- ✅ Artifacts are created
- ✅ JavaDoc is generated
- ✅ Android tests pass

### 3. Deploy Workflow
Create a release:
- ✅ GitHub Release is created with JARs
- ✅ JavaDoc is deployed to GitHub Pages
- ✅ Package is published to Maven Central

## Project Structure

```
stellar-java-sdk/
├── .github/
│   └── workflows/
│       ├── test.yml          # Test workflow
│       ├── build.yml         # Build workflow
│       ├── deploy.yml        # Deployment workflow
│       └── codeql.yml        # Security analysis
├── src/
│   ├── main/java/org/stellar/sdk/
│   └── test/
├── examples/
├── android_test/
├── build.gradle.kts          # ✅ Updated
├── settings.gradle.kts       # ✅ Updated
├── README.md                 # ✅ New
└── SETUP_GUIDE.md            # This file
```

## Important Notes

### Package Names
**Note**: The source code still uses `org.stellar.sdk` package names. This is intentional and does not affect Maven coordinates. Package refactoring is not required unless you want to rebrand the internal package structure.

If you want to refactor packages from `org.stellar` to `io.stellarforge.stellar`, you'll need to:
1. Update all package declarations
2. Update all import statements
3. Update spotless configuration
4. This is a significant change affecting ~1000+ files

### Version Strategy
- Start at `1.0.0` for the fork
- Follow Semantic Versioning (semver.org)
- Breaking changes: Major version (2.0.0)
- New features: Minor version (1.1.0)
- Bug fixes: Patch version (1.0.1)

### Android Compatibility
The SDK supports Android API 23+. Android tests run automatically in CI for:
- API Level 23 (Android 6.0) with Google APIs
- API Level 34 (Android 14) with Play Store

## Troubleshooting

### Build Fails
```bash
# Clean build
./gradlew clean build

# Build with stack trace
./gradlew build --stacktrace
```

### Tests Fail
```bash
# Run specific test
./gradlew test --tests "TestClassName"

# Run with debug output
./gradlew test --debug
```

### Signing Issues
Ensure all three signing environment variables are set:
- `SIGNING_KEY_ID`
- `SIGNING_KEY`
- `SIGNING_PASSWORD`

### Maven Central Publishing
- Verify namespace ownership at central.sonatype.com
- Check GPG key is uploaded to keyserver
- Ensure POM has all required fields

## Support

For issues specific to this setup:
- Create an issue in the repository
- Check GitHub Actions logs
- Review Gradle build output

For Stellar SDK questions:
- Check [Stellar Developers documentation](https://developers.stellar.org/)
- Join [Stellar Developer Discord](https://discord.gg/stellardev)

## Acknowledgments

This SDK is based on the excellent work by the Lightsail Network team. We maintain the original Apache 2.0 license and acknowledge their contributions.

---

**Ready to go!** Your Stellar Java SDK is fully configured and ready for deployment. 🚀
