use snforge_std::{
    declare, 
    ContractClassTrait, 
    DeclareResultTrait,
};
use intro_to_components::ownable_counter::{
    IOwnableCounterDispatcher, 
    IOwnableCounterDispatcherTrait,
};
use core::starknet::ContractAddress;
use intro_to_components::ownable_component::ownable_component::{IOwnableDispatcher, IOwnableDispatcherTrait};

const OWNER: felt252 = 'OWNER';

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
    assert!(owner == OWNER.try_into().unwrap(), "Invalid Owner") 
}
