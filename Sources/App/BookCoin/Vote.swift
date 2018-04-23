//
//  Vote.swift
//  App
//
//  Created by laijihua on 2018/4/23.
//

import Foundation

struct Vote: Codable {
    enum InvalidReason: String, Codable {
        case none
        case double_spend
        case transactions_hash_mismatch
        case nodes_pubkeys_mismatch
    }

    struct Content: Codable {
        var voting_for_block: TBlockID // 所投票的区块 ID
        var is_block_valid: Bool  // 投票结果
        var invalid_reason: InvalidReason  // 区块不合法的原因
        var timestamp: Double // 投票时间
    }
    var node_pubkey: TPublicKey // 投票节点的公钥
    var content: Content //
    var signature: TSignature // 节点需要将vote字段的数据序列化用自己的私钥进行签名
}




