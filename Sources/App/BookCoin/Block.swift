//
//  Block.swift
//  BookCoin
//
//  Created by laijihua on 2018/4/23.
//

import Foundation



typealias TBlockID = String
typealias TPublicKey = String
typealias TSignature = String

struct Block: Codable {
    
    struct Content: Codable {
        var timestamp: Double  // 区块参数的时间
        var transcations: [Transaction] // 当前区块内包括的交易列表
        var node_pubkey: TPublicKey  // 产生该区块的节点的公钥
        var previous_block: TBlockID // 所投票区块的前序区块id
        var voters: [TPublicKey] // 区块链网络中的节点活性强，网络的节点在不断的上线和下线 ， 该字段描述了区块产生的时候，网络中活动的节点的列表，用节点的公钥表示。
    }

    var sha256: Data {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self) else {return Data()}
        return data.sha256
    }

    var id: TBlockID  // 序列化之后的 block 字段所有数据进行哈希运算得到的哈希值
    var content: Content
    var votes: [Vote]  // 默认为空， voters 列表中的节点的投票信息
    var signature: TSignature  // 产生该区块节点提供的签名信息。为了生成签名信息， 节点需要将 block 字段数据序列化并用自己的私钥进行签名
}
