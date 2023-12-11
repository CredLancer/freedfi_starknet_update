// Solidity contract:
// https://github.com/captainahab0x/freedfi/blob/0bd74014d48b55d4da9b8ce60730e63279f885b7/contracts/src/trustcredentials/SimpleCredentialsVerifier.sol
//
use array::ArrayTrait;
use starknet::ContractAddress;

#[starknet::interface]
trait ISimpleCredentialsVerifier<T> {
    fn addSkill(ref self: T, freelancer: ContractAddress, skill: u64);
    fn addContract(ref self: T, freelancer: ContractAddress, client: ContractAddress, skills: u64, amount: u256);

    fn hasOpenContracts(self: @T, freelancer: ContractAddress, amount: u256) -> bool;
    fn hasRequiredSkill(self: @T, freelancer: ContractAddress, skill: u64) -> bool;
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
        owner: ContractAddress,
        contracts: LegacyMap<ContractAddress, List<FreelancingContract>>,
        skills: LegacyMap<ContractAddress, List<u64>>,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.owner.write(get_caller_address());
    }

    #[external(v0)]
    impl SimpleCredentialsVerifierImpl of super::ISimpleCredentialsVerifier<ContractState> {
        fn addSkill(ref self: ContractState, freelancer: ContractAddress, skill: u64) {
            self.only_owner();
            let mut skills = self.skills.read(freelancer);
            skills.append(skill);
        }

        fn addContract(ref self: ContractState, freelancer: ContractAddress, client: ContractAddress, skills: u64, amount: u256) {
            self.only_owner();
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
    }

    #[generate_trait]
    impl PrivateMethods of PrivateMethodsTrait {
        fn only_owner(self: @ContractState) {
            let caller = get_caller_address();
            assert(caller == self.owner.read(), 'Caller is not the owner');
        }
    }
}