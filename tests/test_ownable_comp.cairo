use snforge_std::{
    declare, ContractClassTrait, DeclareResultTrait, start_cheat_caller_address,
    stop_cheat_caller_address
};
use intro_to_components::ownable_counter::{
    IOwnableCounterDispatcher, IOwnableCounterDispatcherTrait,
};
use core::starknet::ContractAddress;
use core::num::traits::Zero;
use intro_to_components::ownable_component::ownable_component::{
    IOwnableDispatcher, IOwnableDispatcherTrait
};

const OWNER: felt252 = 'OWNER';
const BOB: felt252 = 'BOB';

fn __setup__() -> ContractAddress {
    let ownable_counter_class_hash = declare("OwnableCounter").unwrap().contract_class();
    let mut calldata: Array<felt252> = ArrayTrait::new();
    OWNER.serialize(ref calldata);
    let (contract_address, _) = ownable_counter_class_hash.deploy(@calldata).unwrap();
    contract_address
}

#[test]
fn test_initializer() {
    let ownable_counter_contract = __setup__();
    let ownable_comp_dispatcher = IOwnableDispatcher { contract_address: ownable_counter_contract };
    let owner = ownable_comp_dispatcher.owner();
    assert(owner == OWNER.try_into().unwrap(), 'Invalid Owner');
}

#[test]
fn test_transfer_ownership() {
    let ownable_counter_contract = __setup__(); // declares and deploys the contract
    let ownable_comp_dispatcher = IOwnableDispatcher {
        contract_address: ownable_counter_contract
    }; // get the component interface from the dispatcher

    start_cheat_caller_address(
        ownable_counter_contract, OWNER.try_into().unwrap()
    ); //changes the caller address to an address when you typecast OWNER
    ownable_comp_dispatcher
        .transfer_ownership(BOB.try_into().unwrap()); //transfers ownership to BOB address
    let owner = ownable_comp_dispatcher
        .owner(); // gets the new owner, which should be BOB's address
    assert(
        owner == BOB.try_into().unwrap(), 'Invalid Owner'
    ); // confirms that the new owner is BOB.

    stop_cheat_caller_address(ownable_counter_contract);
}

#[test]
fn test_renounce_ownership() {
    let ownable_counter_contract = __setup__();
    let ownable_comp_dispatcher = IOwnableDispatcher { contract_address: ownable_counter_contract };

    start_cheat_caller_address(ownable_counter_contract, OWNER.try_into().unwrap());

    ownable_comp_dispatcher.renounce_ownership();
    let owner = ownable_comp_dispatcher.owner();
    assert(owner == Zero::zero(), 'Renounce Failed');

    stop_cheat_caller_address(ownable_counter_contract);
}

#[test]
#[should_panic(expected: 'Caller not owner')]
fn test_transfer_ownership_not_owner() {
    let ownable_counter_contract = __setup__(); // declares and deploys the contract
    let ownable_comp_dispatcher = IOwnableDispatcher { contract_address: ownable_counter_contract };

    start_cheat_caller_address(ownable_counter_contract, BOB.try_into().unwrap());
    ownable_comp_dispatcher.transfer_ownership(OWNER.try_into().unwrap());

    stop_cheat_caller_address(ownable_counter_contract);
}

#[test]
#[should_panic(expected: 'Owner cannot be address zero')]
fn test_transfer_ownership_address_zero() {
    let ownable_counter_contract = __setup__(); // declares and deploys the contract
    let ownable_comp_dispatcher = IOwnableDispatcher {
        contract_address: ownable_counter_contract
    }; // get the component interface from the dispatcher

    start_cheat_caller_address(
        ownable_counter_contract, OWNER.try_into().unwrap()
    ); //changes the caller address to an address when you typecast OWNER
    ownable_comp_dispatcher
        .transfer_ownership(Zero::zero()); //transfers ownership to zero address which should panic

    stop_cheat_caller_address(ownable_counter_contract);
}

#[test]
#[should_panic(expected: 'Caller cannot be address zero')]
fn test_transfer_ownership_caller_zero() {
    let ownable_counter_contract = __setup__(); // declares and deploys the contract
    let ownable_comp_dispatcher = IOwnableDispatcher {
        contract_address: ownable_counter_contract
    }; // get the component interface from the dispatcher

    start_cheat_caller_address(
        ownable_counter_contract, Zero::zero()
    ); //changes the caller address to a zero address
    ownable_comp_dispatcher
        .transfer_ownership(BOB.try_into().unwrap()); //transfers ownership to BOB address

    stop_cheat_caller_address(ownable_counter_contract);
}

#[test]
#[should_panic(expected: 'Caller not owner')]
fn test_renounce_ownership_failed() {
    let ownable_counter_contract = __setup__();
    let ownable_comp_dispatcher = IOwnableDispatcher { contract_address: ownable_counter_contract };

    start_cheat_caller_address(ownable_counter_contract, BOB.try_into().unwrap());

    ownable_comp_dispatcher.renounce_ownership();

    stop_cheat_caller_address(ownable_counter_contract);
}

#[test]
#[should_panic(expected: 'Caller cannot be address zero')]
fn test_renounce_ownership_zero() {
    let ownable_counter_contract = __setup__();
    let ownable_comp_dispatcher = IOwnableDispatcher { contract_address: ownable_counter_contract };

    start_cheat_caller_address(ownable_counter_contract, Zero::zero());

    ownable_comp_dispatcher.renounce_ownership();

    stop_cheat_caller_address(ownable_counter_contract);
}

#[test]
fn test_increase_count() {
    let ownable_counter_contract = __setup__(); // declares and deploys the contract
    let ownable_counter_dispatcher = IOwnableCounterDispatcher {
        contract_address: ownable_counter_contract
    }; // get the counter interface from the dispatcher

    start_cheat_caller_address(
        ownable_counter_contract, OWNER.try_into().unwrap()
    ); //changes the caller address to owner address

    let counter = ownable_counter_dispatcher.get_counter();
    ownable_counter_dispatcher.increase_count();
    let new_count = ownable_counter_dispatcher.get_counter();

    assert(new_count == 1, 'Increase count failed');

    stop_cheat_caller_address(ownable_counter_contract);
}

#[test]
#[should_panic(expected: 'Caller not owner')]
fn test_increase_count_not_owner() {
    let ownable_counter_contract = __setup__(); // declares and deploys the contract
    let ownable_counter_dispatcher = IOwnableCounterDispatcher {
        contract_address: ownable_counter_contract
    }; // get the counter interface from the dispatcher

    start_cheat_caller_address(
        ownable_counter_contract, BOB.try_into().unwrap()
    ); //changes the caller address to owner address

    ownable_counter_dispatcher.increase_count();

    stop_cheat_caller_address(ownable_counter_contract);
}