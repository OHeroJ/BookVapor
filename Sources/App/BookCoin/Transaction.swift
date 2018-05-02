//
//  Transaction.swift
//  BookCoin
//
//  Created by laijihua on 2018/4/23.
//

import Foundation

enum TransactionType: String, Codable {
    case data
    case normal
    case coinbase
}

final class Transaction: Codable {
    var asset: Data // 资产信息
    var from: Data
    var recipient: Data

    var txnType: TransactionType
    var hash: Data {
        return self.encoded.sha256
    }

    var encoded: Data {
        return Data(from: asset) + from + recipient + Data(from: hash)
    }

    var senderSig: Data?
    var sendPubKey: String?

    var senderAddress: Data?

    init(from: Data = Data(),
         recipient: Data = Data(),
         type: TransactionType = .normal,
         senderSig:Data? = Data(),
         senderPubKey: String? = nil,
         asset: Data = Data()) {
        self.asset = asset
        self.from = from
        self.recipient = recipient
        self.txnType = type
        self.senderSig = senderSig
        self.sendPubKey = senderPubKey
    }

    func createTransaction(source: Wallet, dest: Wallet, input: Data, output: Data) -> Transaction {
        return Transaction()
    }

    func currentBlockReward() -> Data {
        return Data(from: 10)
    }

    func createCoinbase(address: Wallet) -> Transaction {

        guard let address = address.address else {
            return Transaction()
        }
        let txn = Transaction(from: Data(), recipient: address, type: .coinbase, senderSig: nil, senderPubKey: nil, asset: currentBlockReward())
        return txn
    }
}
