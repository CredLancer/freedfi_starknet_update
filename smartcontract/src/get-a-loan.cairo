from starkware.cairo.common.dict_access import DictAccess
from nimbora_toolkit.pooling4626.interface import IPooling4626

//To look if it is necessary to import the following
#[starknet::interface]
trait ISimpleStorage<TContractState> {
    fn set(ref self: TContractState, x: u128);
    fn get(self: @TContractState) -> u128;
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
    amount: felt252
}

#[derive(Drop, starknet::Event)]
struct Repaid {
    #[key]
    lender: ContractAddress,
    #[key]
    borrower: ContractAddress,
    amount: felt252
}


#[starknet::contract]
mod LendingPlatform{
    owner: felt
    
    balances: DictAccess
    borrowedAmounts: DictAccess
    hasActiveLoan: DictAccess


    // Think a way to create event like in solidity 



    func initialize{storage_ptr : Storage*, pedersen_ptr : HashBuiltin*}() -> (Storage*):

        let (storage_ptr, owner) = Storage.write{storage_ptr=storage_ptr}(key='owner', value=<sender>)
        if <value> > 0:
            let storage_ptr = deposit{storage_ptr=storage_ptr, pedersen_ptr=pedersen_ptr}(<value>)
        end

        return (storage_ptr)
    end


    func assert_only_owner{storage_ptr : Storage*}(owner: felt, sender: felt) -> ():
        assert owner = sender, "Only owner can perform this action"
        return ()
    end

    func repay{storage_ptr : Storage*, pedersen_ptr : HashBuiltin*}(lender: felt, borrower: felt, value: felt) -> (Storage*):

        let (storage_ptr, borrowed_amount) = Storage.read{storage_ptr=storage_ptr}(key=borrower)
        assert borrowed_amount > 0, "Borrower has no borrowed amount to repay"

        assert borrower = <sender>, "Only borrower can repay"

        assert value = borrowed_amount, "You must repay the full borrowed amount"

        borrowed_amount = 0
        let (storage_ptr, borrower_has_active_loan) = Storage.read{storage_ptr=storage_ptr}(key=borrower)
        borrower_has_active_loan = 0

        let (storage_ptr, lender_balance) = Storage.read{storage_ptr=storage_ptr}(key=lender)
        lender_balance += value

        let storage_ptr = Storage.write{storage_ptr=storage_ptr}(key=borrower, value=borrowed_amount)
        let storage_ptr = Storage.write{storage_ptr=storage_ptr}(key=borrower, value=borrower_has_active_loan)
        let storage_ptr = Storage.write{storage_ptr=storage_ptr}(key=lender, value=lender_balance)

        self.emit(Repaid { lender: lender, borrower: borrower, amount: value })

  
        return (storage_ptr)
    end 


    func deposit{storage_ptr : Storage*, pedersen_ptr : HashBuiltin*}(sender: felt, value: felt) -> (Storage*):
        assert_only_owner{storage_ptr=storage_ptr}(owner=<owner>, sender=sender)

        assert value > 0, "Deposit amount must be greater than zero"

        let (storage_ptr, balance) = Storage.read{storage_ptr=storage_ptr}(key='balance')
        balance += value
        let storage_ptr = Storage.write{storage_ptr=storage_ptr}(key='balance', value=balance)

        return (storage_ptr)
    end

    func borrow{storage_ptr : Storage*, pedersen_ptr : HashBuiltin*}(lender: felt, borrower: felt, amount: felt) -> (Storage*):

        assert amount > 0, "Borrowed amount must be greater than zero"

        let (storage_ptr, lender_balance) = Storage.read{storage_ptr=storage_ptr}(key=lender)
        assert lender_balance >= amount, "Lender has insufficient balance"

        let (storage_ptr, borrower_has_active_loan) = Storage.read{storage_ptr=storage_ptr}(key=borrower)
        assert borrower_has_active_loan = 0, "Borrower can only borrow one loan at a time"

        lender_balance -= amount
        let (storage_ptr, borrower_borrowed_amount) = Storage.read{storage_ptr=storage_ptr}(key=borrower)
        borrower_borrowed_amount = amount
        borrower_has_active_loan = 1

        let storage_ptr = Storage.write{storage_ptr=storage_ptr}(key=lender, value=lender_balance)
        let storage_ptr = Storage.write{storage_ptr=storage_ptr}(key=borrower, value=borrower_borrowed_amount)
        let storage_ptr = Storage.write{storage_ptr=storage_ptr}(key=borrower, value=borrower_has_active_loan)

        self.emit(Borrowed { lender: lender, borrower: borrower, amount: amount })
   
        return (storage_ptr)
    end 


    func getBalance{storage_ptr : Storage*}(sender: felt) -> (felt):
        let (storage_ptr, balance) = Storage.read{storage_ptr=storage_ptr}(key=sender)
    return (balance)
    end

    func getBorrowedAmount{storage_ptr : Storage*}(sender: felt) -> (felt):
        let (storage_ptr, borrowed_amount) = Storage.read{storage_ptr=storage_ptr}(key=sender)
    return (borrowed_amount)
    end

end
}

#[cfg(test)]
mod tests {
   
}
