//
//  ChainController.swift
//  App
//
//  Created by laijihua on 2018/4/25.
//

import Vapor 

final class ChainController {

    func blocks(_ req: Request) throws -> Future<[Block]> {
        let promiss = req.eventLoop.newPromise([Block].self)
        promiss.succeed(result: BlockState.shared.blockchain.chain)
        return promiss.futureResult
    }
}
