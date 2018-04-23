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

struct TransactionInput: Codable {
    var content: String
}


struct Transaction: Codable {
    var asset: Data // 资产信息
    var from: Data
    var recipient: Data
    var txnType: TransactionType
    var tnxHash: Data {
        return self.encoded.sha256
    }

    var encoded: Data {
        return Data(from: asset) + from + recipient + Data(from: txnType)
    }
}
