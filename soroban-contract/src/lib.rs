#![no_std]
use soroban_sdk::{contract, contractimpl, contracttype, symbol_short, Env, String, Symbol};

/// Stellar Forge SDK Registry Contract
/// 
/// This contract serves as an on-chain registry for the Stellar Java SDK project.
/// It stores project metadata and provides versioning information.

#[contracttype]
#[derive(Clone)]
pub struct SDKInfo {
    pub name: String,
    pub version: String,
    pub organization: String,
    pub group_id: String,
    pub artifact_id: String,
    pub repository: String,
    pub description: String,
}

#[contracttype]
#[derive(Clone)]
pub struct Stats {
    pub total_tests: u32,
    pub version_count: u32,
    pub last_updated: u64,
}

const SDK_INFO: Symbol = symbol_short!("SDK_INFO");
const STATS: Symbol = symbol_short!("STATS");
const OWNER: Symbol = symbol_short!("OWNER");

#[contract]
pub struct StellarForgeSDK;

#[contractimpl]
impl StellarForgeSDK {
    /// Initialize the contract with SDK information
    pub fn initialize(
        env: Env,
        name: String,
        version: String,
        organization: String,
        group_id: String,
        artifact_id: String,
        repository: String,
        description: String,
        owner: soroban_sdk::Address,
    ) {
        // Ensure contract is not already initialized
        if env.storage().instance().has(&SDK_INFO) {
            panic!("Contract already initialized");
        }

        let sdk_info = SDKInfo {
            name,
            version,
            organization,
            group_id,
            artifact_id,
            repository,
            description,
        };

        let stats = Stats {
            total_tests: 1228,
            version_count: 1,
            last_updated: env.ledger().timestamp(),
        };

        env.storage().instance().set(&SDK_INFO, &sdk_info);
        env.storage().instance().set(&STATS, &stats);
        env.storage().instance().set(&OWNER, &owner);
    }

    /// Get SDK information
    pub fn get_sdk_info(env: Env) -> SDKInfo {
        env.storage()
            .instance()
            .get(&SDK_INFO)
            .unwrap_or_else(|| panic!("Not initialized"))
    }

    /// Get SDK statistics
    pub fn get_stats(env: Env) -> Stats {
        env.storage()
            .instance()
            .get(&STATS)
            .unwrap_or_else(|| panic!("Not initialized"))
    }

    /// Update version (only owner can call)
    pub fn update_version(env: Env, caller: soroban_sdk::Address, new_version: String) {
        caller.require_auth();

        let owner: soroban_sdk::Address = env
            .storage()
            .instance()
            .get(&OWNER)
            .unwrap_or_else(|| panic!("Not initialized"));

        if caller != owner {
            panic!("Only owner can update version");
        }

        let mut sdk_info: SDKInfo = env
            .storage()
            .instance()
            .get(&SDK_INFO)
            .unwrap_or_else(|| panic!("Not initialized"));

        sdk_info.version = new_version;

        let mut stats: Stats = env.storage().instance().get(&STATS).unwrap();
        stats.version_count += 1;
        stats.last_updated = env.ledger().timestamp();

        env.storage().instance().set(&SDK_INFO, &sdk_info);
        env.storage().instance().set(&STATS, &stats);
    }

    /// Get contract version (for version tracking)
    pub fn version(env: Env) -> String {
        let sdk_info: SDKInfo = env
            .storage()
            .instance()
            .get(&SDK_INFO)
            .unwrap_or_else(|| panic!("Not initialized"));
        sdk_info.version
    }

    /// Check if contract is initialized
    pub fn is_initialized(env: Env) -> bool {
        env.storage().instance().has(&SDK_INFO)
    }

    /// Get repository URL
    pub fn get_repository(env: Env) -> String {
        let sdk_info: SDKInfo = env
            .storage()
            .instance()
            .get(&SDK_INFO)
            .unwrap_or_else(|| panic!("Not initialized"));
        sdk_info.repository
    }

    /// Get Maven coordinates
    pub fn get_maven_coordinates(env: Env) -> (String, String) {
        let sdk_info: SDKInfo = env
            .storage()
            .instance()
            .get(&SDK_INFO)
            .unwrap_or_else(|| panic!("Not initialized"));
        (sdk_info.group_id, sdk_info.artifact_id)
    }
}

#[cfg(test)]
mod test {
    use super::*;
    use soroban_sdk::{testutils::Address as _, Address, Env, String};

    #[test]
    fn test_initialize_and_get() {
        let env = Env::default();
        let contract_id = env.register_contract(None, StellarForgeSDK);
        let client = StellarForgeSDKClient::new(&env, &contract_id);

        let owner = Address::generate(&env);

        client.initialize(
            &String::from_str(&env, "Stellar Java SDK"),
            &String::from_str(&env, "1.0.0"),
            &String::from_str(&env, "StellarForge"),
            &String::from_str(&env, "io.stellarforge"),
            &String::from_str(&env, "stellar-java-sdk"),
            &String::from_str(&env, "https://github.com/damianosakwe/stellar-java-sdk"),
            &String::from_str(&env, "Comprehensive Java SDK for Stellar blockchain"),
            &owner,
        );

        let sdk_info = client.get_sdk_info();
        assert_eq!(sdk_info.name, String::from_str(&env, "Stellar Java SDK"));
        assert_eq!(sdk_info.version, String::from_str(&env, "1.0.0"));

        let stats = client.get_stats();
        assert_eq!(stats.total_tests, 1228);
        assert_eq!(stats.version_count, 1);

        assert!(client.is_initialized());
    }

    #[test]
    fn test_version() {
        let env = Env::default();
        let contract_id = env.register_contract(None, StellarForgeSDK);
        let client = StellarForgeSDKClient::new(&env, &contract_id);

        let owner = Address::generate(&env);

        client.initialize(
            &String::from_str(&env, "Stellar Java SDK"),
            &String::from_str(&env, "1.0.0"),
            &String::from_str(&env, "StellarForge"),
            &String::from_str(&env, "io.stellarforge"),
            &String::from_str(&env, "stellar-java-sdk"),
            &String::from_str(&env, "https://github.com/damianosakwe/stellar-java-sdk"),
            &String::from_str(&env, "Comprehensive Java SDK for Stellar blockchain"),
            &owner,
        );

        let version = client.version();
        assert_eq!(version, String::from_str(&env, "1.0.0"));
    }
}
