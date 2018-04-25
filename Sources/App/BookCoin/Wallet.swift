//
//  Wallet.swift
//  App
//
//  Created by laijihua on 2018/4/25.
//

import Foundation

class Wallet {
    var pubKey: String?
    var privKey: String?

    var address: Data?
    var readableAddress: String?

    func signTransaction(transaction: Transaction) -> Data {
        // TODO
        return Data()
    }

    func signMessage(msg: Data, priv: Wallet) -> Data {
        return Data()
    }

    func checkSignature(msg: Data, sign: Wallet) -> Bool {
        return false
    }

}
