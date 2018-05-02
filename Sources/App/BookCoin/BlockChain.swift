//
//  BlockChain.swift
//  BookCoin
//
//  Created by laijihua on 2018/4/23.
//

import Foundation

final class BlockChain {
    var chain: [Block]
    var depth: Int

    init() {
        self.chain = []
        self.depth = 1
        self.chain.append(Block.genesis)
    }

    func append(_ block: Block) {
        if block.isValid {
            self.chain.append(block)
            self.depth += 1
        } else {
            ///
        }
    }

    func block(hash: Data) -> Block {
        let block = self.chain.filter{ $0.hash == hash }.first
        guard let ret = block else{
            return Block()
        }
        return ret
    }

    var lastBlock: Block {
        return self.chain.last ?? Block.genesis
    }
}


