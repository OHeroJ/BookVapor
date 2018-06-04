//
//  ChainController.swift
//  App
//
//  Created by laijihua on 2018/4/25.
//

import Vapor 

final class ChainController: RouteCollection {

    func boot(router: Router) throws {
        router.get("blocks", use: blocks)
    }

    private func blocks(_ req: Request) throws -> Future<[Block]> {
        let promiss = req.eventLoop.newPromise([Block].self)
        promiss.succeed(result: BlockState.shared.blockchain.chain)
        return promiss.futureResult
    }
}
