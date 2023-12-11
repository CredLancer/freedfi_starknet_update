use starknet::{
    get_contract_address, deploy_syscall, ClassHash, contract_address_const, ContractAddress,
};
use starknet::testing::{set_caller_address, set_contract_address, pop_log_raw};
// use snforge_std::{ declare, ContractClassTrait };

use freefi::simple_credentials_verifier::{ISimpleCredentialsVerifierDispatcher, ISimpleCredentialsVerifierDispatcherTrait, SimpleCredentialsVerifier};
use freefi::simple_credentials_verifier::SimpleCredentialsVerifier::OwnerShipTransferred;

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
    let owner = get_contract_address();
    let mut constructor_args: Array<felt252> = ArrayTrait::new();
    Serde::serialize(@owner, ref constructor_args);
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

#[test]
#[available_gas(3000000)]
#[should_panic(expected: ('Caller is not the owner', 'ENTRYPOINT_FAILED'))]
fn test_add_skill_only_owner() {
    let verifier = deploy();
    let skill = 12;
    set_contract_address(alice());
    verifier.addSkill(alice(), skill);
    assert(verifier.hasRequiredSkill(alice(), skill), 'Fail to verify skill');
}

#[test]
#[available_gas(3000000)]
fn test_get_owner() {
    let lending = deploy();
    let owner = get_contract_address();
    assert(owner == lending.owner(), 'Wrong owner');
}

#[test]
#[available_gas(3000000)]
fn test_transfer_ownership() {
    let verifier = deploy();
    let skill = 12;
    let new_owner = alice();
    verifier.transfer_ownership(new_owner);
    set_contract_address(new_owner);
    verifier.addSkill(bob(), skill);
    assert(verifier.hasRequiredSkill(bob(), skill), 'Fail to verify skill');
}