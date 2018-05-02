//
//  Block.swift
//  BookCoin
//
//  Created by laijihua on 2018/4/23.
//

import Foundation
import Vapor


final class Block: Content {
    let prevHash: Data // 上一个区块的 hash
    // 每个区块存放的信息
    var merkRoot: Data
    let timeStamp: TimeInterval
    // 挖矿的工作量证明
    let nonce: Int
    var transactions: [Transaction]


    var hash: Data {
        return self.encoded.sha256
    }

    var encoded: Data {
        return prevHash + merkRoot + Data(from: timeStamp) + Data(from: nonce)
    }

    var sha256: Data {
        return self.encoded.sha256
    }

    init(prevHash: Data = Data(),
         transactions: [Transaction] = [],
         timestamp: TimeInterval = 0,
         nonce: Int = 0) {
        self.prevHash = prevHash
        self.transactions = transactions
        self.timeStamp = timestamp
        self.nonce = nonce
        self.merkRoot = MerkleRoot.getRootHash(fromTransactions: transactions)
    }

    func copy() -> Block {
        return Block(prevHash: prevHash, transactions: transactions, timestamp: timeStamp, nonce: nonce)
    }

    /// 创世区块
    static var genesis: Block {
        return Block(prevHash: Data(bytes: Array(repeating: 0, count: 32)), transactions: [], timestamp: 1505278315, nonce: 0)
    }
}

extension Block {
    var isValid: Bool {
        guard self.hash == self.sha256 else { return false }
        guard self.prevHash == BlockState.shared.blockchain.lastBlock.hash else {return false }
        guard self.merkRoot == MerkleRoot.getRootHash(fromTransactions: self.transactions) else {return false}

        let currentTime = Date().timeIntervalSince1970
        if self.timeStamp < currentTime - BlockState.maxTimeDeviation {
            return false
        }
        if self.timeStamp > currentTime + BlockState.maxTimeDeviation {
            return false
        }
        return true
    }
}


