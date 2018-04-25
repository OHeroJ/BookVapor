//
//  State.swift
//  App
//
//  Created by laijihua on 2018/4/25.
//

import Foundation
import Vapor

class PeerState: Hashable {
    var hashValue: Int {
        return self.id
    }

    static func == (lhs: PeerState, rhs: PeerState) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    var hostName: String
    var id: Int
    var clientVersion: Int
    var clientType: String

    init(hostName: String, clientVersion: Int, clientType: String) {
        self.hostName = hostName
        self.clientVersion = clientVersion
        self.clientType = clientType
        // TODO:
        self.id = 4
    }
}

class BlockState {
    var blockchain: BlockChain
    var peers: [PeerState: WebSocket] = [:]

    var wallet: Wallet? = nil


    var clientVersion = 1
    var clientType    = "hype-fullnode"
    let version = 1 

    /// 区间
    static let maxTimeDeviation: TimeInterval = 1000

    static let shared: BlockState = BlockState()



    init() {
        self.blockchain = BlockChain()
    }

}
