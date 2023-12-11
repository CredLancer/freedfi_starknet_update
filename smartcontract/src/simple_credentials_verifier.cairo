// Solidity contract:
// https://github.com/captainahab0x/freedfi/blob/0bd74014d48b55d4da9b8ce60730e63279f885b7/contracts/src/trustcredentials/SimpleCredentialsVerifier.sol
//
use array::ArrayTrait;
use starknet::ContractAddress;

#[starknet::interface]
trait ISimpleCredentialsVerifier<T> {
    fn transfer_ownership(ref self: T, new_owner: ContractAddress);
    fn addSkill(ref self: T, freelancer: ContractAddress, skill: u64);
    fn addContract(ref self: T, freelancer: ContractAddress, client: ContractAddress, skills: u64, amount: u256);

    fn hasOpenContracts(self: @T, freelancer: ContractAddress, amount: u256) -> bool;
    fn hasRequiredSkill(self: @T, freelancer: ContractAddress, skill: u64) -> bool;
    fn owner(self: @T) -> ContractAddress;
}


#[starknet::contract]
mod SimpleCredentialsVerifier{
    use starknet::{ContractAddress, get_caller_address};
    use alexandria_storage::list::{List, ListTrait};

    #[derive(Copy, Drop, Serde, starknet::Store)]
    struct FreelancingContract {
        client: ContractAddress,
        freelancer: ContractAddress,
        amount: u256,
        skills: u64,
        isCompleted: bool,
    }

    #[storage]
    struct Storage {
        _owner: ContractAddress,
        contracts: LegacyMap<ContractAddress, List<FreelancingContract>>,
        skills: LegacyMap<ContractAddress, List<u64>>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        OwnerShipTransferred: OwnerShipTransferred,
    }

    #[derive(Drop, starknet::Event)]
    struct OwnerShipTransferred {
        previous_owner: ContractAddress,
        new_owner: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self._owner.write(owner);
    }

    #[external(v0)]
    impl SimpleCredentialsVerifierImpl of super::ISimpleCredentialsVerifier<ContractState> {
        fn transfer_ownership(ref self: ContractState, new_owner: ContractAddress) {
            assert(new_owner.is_non_zero(), 'New owner can\'t be zero');
            self._only_owner();
            self._transfer_ownership(new_owner);
        }

        fn addSkill(ref self: ContractState, freelancer: ContractAddress, skill: u64) {
            self._only_owner();
            let mut skills = self.skills.read(freelancer);
            skills.append(skill);
        }

        fn addContract(ref self: ContractState, freelancer: ContractAddress, client: ContractAddress, skills: u64, amount: u256) {
            self._only_owner();
        }

        fn hasOpenContracts(self: @ContractState, freelancer: ContractAddress, amount: u256) -> bool {
            false
        }

        fn hasRequiredSkill(self: @ContractState, freelancer: ContractAddress, skill: u64) -> bool {
            let skills = self.skills.read(freelancer);
            let mut index = 0;
            loop {
                if index > skills.len() {
                    break false;
                }
                if skills[index] == skill {
                    break true;
                }
                index += 1;
            }
        }

        fn owner(self: @ContractState) -> ContractAddress {
            self._owner.read()
        }
    }

    #[generate_trait]
    impl PrivateMethods of PrivateMethodsTrait {
        fn _only_owner(self: @ContractState) {
            let caller = get_caller_address();
            assert(caller == self._owner.read(), 'Caller is not the owner');
        }

        fn _transfer_ownership(ref self: ContractState, new_owner: ContractAddress) {
            let previous_owner: ContractAddress = self._owner.read();
            self._owner.write(new_owner);
            self.emit(OwnerShipTransferred{ previous_owner: previous_owner, new_owner: new_owner })
        }
    }
}