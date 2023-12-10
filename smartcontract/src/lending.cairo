use starknet::ContractAddress;
use freefi::interfaces::nimbora::IPooling4626Dispatcher;

#[starknet::interface]
trait ILendingPlatform<T> {
    fn deposit(ref self: T, address: ContractAddress, amount: u256);
    fn borrow(ref self: T, lender: ContractAddress, borrower: ContractAddress, amount: u256);
    fn repay(ref self: T, lender: ContractAddress, borrower: ContractAddress, amount: u256);
    fn getBalance(self: @T, lender: ContractAddress) -> u256;
    fn getBorrowedAmount(self: @T, borrower: ContractAddress) -> u256;
}

#[starknet::contract]
mod LendingPlatform{
    use starknet::{ContractAddress, get_caller_address};

    #[storage]
    struct Storage {
        balances: LegacyMap<ContractAddress, u256>,
        borrowed_amount: LegacyMap<ContractAddress, u256>,
        has_active_loan: LegacyMap<ContractAddress, bool>,
        owner: ContractAddress,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Borrowed: Borrowed,
        Repaid: Repaid,
    }

    #[derive(Drop, starknet::Event)]
    struct Borrowed {
        #[key]
        lender: ContractAddress,
        #[key]
        borrower: ContractAddress,
        amount: u256
    }

    #[derive(Drop, starknet::Event)]
    struct Repaid {
        #[key]
        lender: ContractAddress,
        #[key]
        borrower: ContractAddress,
        amount: u256
    }
    
    #[constructor]
    fn constructor(ref self: ContractState) {
        self.owner.write(get_caller_address());
    }

    #[external(v0)]
    impl LendingPlatformImpl of super::ILendingPlatform<ContractState> {
        fn deposit(ref self: ContractState, address: ContractAddress, amount: u256) {
            self.only_owner();
            assert(amount > 0, 'Amount must be greater than 0');
            let balance = self.balances.read(address);
            self.balances.write(address, balance + amount);
        }

        fn borrow(ref self: ContractState, lender: ContractAddress, borrower: ContractAddress, amount: u256) {
            let caller = get_caller_address();
            assert(caller == lender, 'Only lender can allow borrow');
            assert(amount > 0, 'Amount must be greater than 0');
            let mut balance = self.balances.read(lender);
            assert(balance >= amount, 'Lender has insufficient balance');
            let has_active = self.has_active_loan.read(borrower);
            assert(!has_active, 'Can only borrow one loan');
            balance -= amount;
            self.has_active_loan.write(borrower, true);
            self.borrowed_amount.write(borrower, amount);
            self.balances.write(lender, balance);
        }

        fn repay(ref self: ContractState, lender: ContractAddress, borrower: ContractAddress, amount: u256) {
            let caller = get_caller_address();
            assert(caller == borrower, 'Only borrower can repay');
            let borrowed = self.borrowed_amount.read(borrower);
            assert(borrowed > 0, 'No borrowed amount to repay');
            assert(amount == borrowed, 'You must repay full amount');
            let balance = self.balances.read(lender);
            self.balances.write(lender, balance + amount);
            self.borrowed_amount.write(borrower, 0);
            self.has_active_loan.write(borrower, false);
        }

        fn getBalance(self: @ContractState, lender: ContractAddress) -> u256 {
            self.balances.read(lender)
        }

        fn getBorrowedAmount(self: @ContractState, borrower: ContractAddress) -> u256 {
            self.borrowed_amount.read(borrower)
        }
    }

    #[generate_trait]
    impl PrivateMethods of PrivateMethodsTrait {
        fn only_owner(self: @ContractState) {
            let caller = get_caller_address();
            assert(caller == self.owner.read(), 'Caller is not the owner');
        }
    }

}

