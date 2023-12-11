use starknet::{
    get_contract_address, deploy_syscall, ClassHash, contract_address_const, ContractAddress,
};
use starknet::testing::{set_caller_address, set_contract_address, pop_log_raw};

use freefi::simple_credentials_verifier::{ISimpleCredentialsVerifierDispatcher, ISimpleCredentialsVerifierDispatcherTrait, SimpleCredentialsVerifier};

fn alice() -> ContractAddress {
    contract_address_const::<42>()
}

fn bob() -> ContractAddress {
    contract_address_const::<43>()
}

fn jdoe() -> ContractAddress {
    contract_address_const::<4269>()
}

fn deploy() -> ISimpleCredentialsVerifierDispatcher {
    let constructor_args: Array<felt252> = ArrayTrait::new();
    let (address, _) = deploy_syscall(
        SimpleCredentialsVerifier::TEST_CLASS_HASH.try_into().unwrap(), 0, constructor_args.span(), true
    ).expect('DEPLOY FAILED');
    return ISimpleCredentialsVerifierDispatcher { contract_address: address};
}

#[test]
#[available_gas(3000000)]
fn test_add_skill() {
    let verifier = deploy();
    let skill = 12;
    verifier.addSkill(alice(), skill);
    assert(verifier.hasRequiredSkill(alice(), skill), 'Fail to verify skill');
}
