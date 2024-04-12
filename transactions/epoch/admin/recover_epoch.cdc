import FlowEpoch from 0xEPOCHADDRESS
import FlowIDTableStaking from 0xIDENTITYTABLEADDRESS
import FlowClusterQC from 0xQCADDRESS
// The recoverEpoch transaction creates and starts a new epoch in the FlowEpoch smart contract
// to which will force the network exit EFM. The recoverEpoch service event will be emitted 
// and processed by all protocol participants and each participant will update their protocol 
// state with the new Epoch data.
// This transaction should only be used with the output of the bootstrap utility:
//   util epoch efm-recover-tx-args
transaction(randomSource: String,
            startView: UInt64,
            stakingEndView: UInt64,
            endView: UInt64,
            collectorClusters: [[String]],
            clusterQCVoteData: [FlowClusterQC.ClusterQCVoteData],
            dkgPubKeys: [String],
            nodeIDs: [String]) {

    prepare(signer: AuthAccount) {
        let epochAdmin = signer.borrow<&FlowEpoch.Admin>(from: FlowEpoch.adminStoragePath)
            ?? panic("Could not borrow epoch admin from storage path")

        epochAdmin.recoverEpoch(randomSource: randomSource,
                             startView: startView,
                             stakingEndView: stakingEndView,
                             endView: endView,
                             collectorClusters: collectorClusters,
                             clusterQCVoteData: clusterQCVoteData,
                             dkgPubKeys: dkgPubKeys,
                             nodeIDs: nodeIDs)
    }
}
