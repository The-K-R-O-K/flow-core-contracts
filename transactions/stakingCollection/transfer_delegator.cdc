import FlowStakingCollection from "FlowStakingCollection"

// Transfers a NodeDelegator object from an authorizers account
// and adds the NodeDelegator to another accounts Staking Collection
// identified by the to Address.

transaction(nodeID: String, delegatorID: UInt32, to: Address) {
    let fromStakingCollectionRef: auth(FlowStakingCollection.CollectionOwner) &FlowStakingCollection.StakingCollection
    let toStakingCollectionCap: &FlowStakingCollection.StakingCollection

    prepare(account: auth(BorrowValue) &Account) {
        // The account to transfer the NodeDelegator object to must have a valid Staking Collection in order to receive the NodeDelegator.
        if (!FlowStakingCollection.doesAccountHaveStakingCollection(address: to)) {
            panic("Destination account must have a Staking Collection set up.")
        }

        // Get a reference to the authorizers StakingCollection
        self.fromStakingCollectionRef = account.storage.borrow<auth(FlowStakingCollection.CollectionOwner) &FlowStakingCollection.StakingCollection>(from: FlowStakingCollection.StakingCollectionStoragePath)
            ?? panic("Could not borrow a reference to a StakingCollection in the primary user's account")

        // Get the PublicAccount of the account to transfer the NodeDelegator to. 
        let toAccount = getAccount(to)

        // Borrow a capability to the public methods available on the receivers StakingCollection.
        self.toStakingCollectionCap = toAccount.capabilities
            .borrow<&FlowStakingCollection.StakingCollection>(FlowStakingCollection.StakingCollectionPublicPath)
            ?? panic("Could not borrow a referamce to a StakingCollection in the receiver's account")
    }

    execute {
        // Remove the NodeDelegator from the authorizers StakingCollection.
        let nodeDelegator <- self.fromStakingCollectionRef.removeDelegator(nodeID: nodeID, delegatorID: delegatorID)

        // Deposit the NodeDelegator to the receivers StakingCollection.
        self.toStakingCollectionCap.addDelegatorObject(<- nodeDelegator!)
    }
}