#[starknet::interface]
pub trait IOwnableCounter<TContractState> {
    fn increase_count(ref self: TContractState);
}

#[starknet::contract]
mod OwnableCounter {
    use ownable_component::PrivateTrait;
    use core::starknet::{ContractAddress};
    use intro_to_components::ownable_component::ownable_component::ownable_component;
    use core::starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use super::IOwnableCounter;

    component!(path: ownable_component, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl OwnableImpl = ownable_component::Ownable<ContractState>;

    impl OwnableInternalImpl = ownable_component::PrivateImpl<ContractState>;

    #[storage]
    struct Storage {
        counter: u128,
        #[substorage(v0)]
        ownable: ownable_component::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        OwnableEvent: ownable_component::Event
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.ownable.initializer(owner);
    }

    #[abi(embed_v0)]
    impl OwnableCounterImpl of IOwnableCounter<ContractState> {
        fn increase_count(ref self: ContractState) {
            self.ownable.assert_only_owner();
            self.counter.write(self.counter.read() + 1);
        }
    }
  
}
