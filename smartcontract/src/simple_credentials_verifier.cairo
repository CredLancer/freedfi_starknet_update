use array::ArrayTrait;
use starknet::ContractAddress;

#[starknet::interface]
trait ISimpleCredentialsVerifier<T> {
    fn addSkills(ref self: T, freelancer: ContractAddress, skill: u64);
    fn addContract(ref self: T, freelancer: ContractAddress, amount: u256);

    fn hasOpenContracts(self: @T, freelancer: ContractAddress, amount: u256) -> bool;
    fn hasRequiredSkills(self: @T, freelancer: ContractAddress, skills: u64) -> bool;
}


#[starknet::contract]
mod SimpleCredentialsVerifier{
    use starknet::{ContractAddress, get_caller_address};

    // #[derive(Drop, Serde)]
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
        // contracts: LegacyMap<ContractAddress, Array<FreelancingContract>>,
        skills: LegacyMap<ContractAddress, u64>,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.owner.write(get_caller_address());
    }

    #[generate_trait]
    impl PrivateMethods of PrivateMethodsTrait {
        fn only_owner(self: @ContractState) {
            let caller = get_caller_address();
            assert(caller == self.owner.read(), 'Caller is not the owner');
        }
    }
}