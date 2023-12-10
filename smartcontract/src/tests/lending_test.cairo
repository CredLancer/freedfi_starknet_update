use starknet::{
    get_contract_address, deploy_syscall, ClassHash, contract_address_const, ContractAddress,
};
use starknet::testing::{set_caller_address, set_contract_address};

use freefi::lending::{ILendingPlatformDispatcher, ILendingPlatformDispatcherTrait, LendingPlatform};

fn alice() -> ContractAddress {
    contract_address_const::<42>()
}

fn bob() -> ContractAddress {
    contract_address_const::<43>()
}

fn jdoe() -> ContractAddress {
    contract_address_const::<4269>()
}

fn deploy() -> ILendingPlatformDispatcher {
    let constructor_args: Array<felt252> = ArrayTrait::new();
    let (address, _) = deploy_syscall(
        LendingPlatform::TEST_CLASS_HASH.try_into().unwrap(), 0, constructor_args.span(), true
    ).expect('DEPLOY FAILED');
    return ILendingPlatformDispatcher { contract_address: address};
}

#[test]
#[available_gas(3000000)]
fn test_deploy() {
    let lending = deploy();
    assert(lending.contract_address != contract_address_const::<0>(), 'Contracta address is zero');
}

#[test]
#[available_gas(3000000)]
fn test_deposit() {
    let lending = deploy();
    lending.deposit(alice(), 30);
    assert(lending.getBalance(alice()) == 30, 'Invalid balance');
}

#[test]
#[available_gas(3000000)]
#[should_panic(expected: ('Amount must be greater than 0', 'ENTRYPOINT_FAILED'))]
fn test_deposit_amount_0() {
    let lending = deploy();
    lending.deposit(alice(), 0);
}
#[test]
#[available_gas(3000000)]
fn test_borrow() {
    let lender = alice();
    let borrower = bob();
    let lending = deploy();
    lending.deposit(lender, 50);
    set_contract_address(lender);
    lending.borrow(lender, borrower, 30);
    assert(lending.getBalance(lender) == 20, 'Invalid balance');
    assert(lending.getBorrowedAmount(borrower) == 30, 'Invalid borrowed amount');
}

#[test]
#[available_gas(3000000)]
#[should_panic(expected: ('Only lender can allow borrow', 'ENTRYPOINT_FAILED'))]
fn test_borrow_only_lender() {
    let lender = alice();
    let borrower = bob();
    let lending = deploy();
    lending.borrow(lender, borrower, 15);
}

#[test]
#[available_gas(3000000)]
#[should_panic(expected: ('Amount must be greater than 0', 'ENTRYPOINT_FAILED'))]
fn test_borrow_amount_0() {
    let lender = alice();
    let borrower = bob();
    let lending = deploy();
    set_contract_address(lender);
    lending.borrow(lender, borrower, 0);
}

#[test]
#[available_gas(3000000)]
#[should_panic(expected: ('Lender has insufficient balance', 'ENTRYPOINT_FAILED'))]
fn test_borrow_insufficient_balance() {
    let lender = alice();
    let borrower = bob();
    let lending = deploy();
    set_contract_address(lender);
    lending.borrow(lender, borrower, 15);
}


#[test]
#[available_gas(3000000)]
fn test_repay() {
    let lender = alice();
    let borrower = bob();
    let amount = 20;
    let deposit = amount + 10;
    let lending = deploy();
    lending.deposit(lender, deposit);
    set_contract_address(lender);
    lending.borrow(lender, borrower, amount);
    set_contract_address(borrower);
    lending.repay(lender, borrower, amount);
    assert(lending.getBalance(lender) == deposit, 'Invalid balance after repay');
    assert(lending.getBorrowedAmount(borrower) == 0, 'Invalid borrowed amount');
}

#[test]
#[available_gas(3000000)]
#[should_panic(expected: ('Only borrower can repay', 'ENTRYPOINT_FAILED'))]
fn test_repay_only_borrower() {
    let lender = alice();
    let borrower = bob();
    let amount = 20;
    let deposit = amount + 10;
    let lending = deploy();
    lending.deposit(lender, deposit);
    set_contract_address(lender);
    lending.borrow(lender, borrower, amount);
    lending.repay(lender, borrower, amount);
}

#[test]
#[available_gas(3000000)]
#[should_panic(expected: ('You must repay full amount', 'ENTRYPOINT_FAILED'))]
fn test_repay_not_full_amount() {
    let lender = alice();
    let borrower = bob();
    let amount = 20;
    let deposit = amount + 10;
    let lending = deploy();
    lending.deposit(lender, deposit);
    set_contract_address(lender);
    lending.borrow(lender, borrower, amount);
    set_contract_address(borrower);
    lending.repay(lender, borrower, amount - 5);
}

