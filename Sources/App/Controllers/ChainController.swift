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

    /// Returns a list of all `Todo`s.
    func index(_ req: Request) throws -> Future<[Todo]> {
        return Todo.query(on: req).all()
    }

    /// Saves a decoded `Todo` to the database.
    func create(_ req: Request) throws -> Future<Todo> {
        return try req.content.decode(Todo.self).flatMap(to: Todo.self) { todo in
            return todo.save(on: req)
        }
    }

    /// Deletes a parameterized `Todo`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Todo.self).flatMap(to: Void.self) { todo in
            return todo.delete(on: req)
            }.transform(to: .ok)
    }

    func test(_ req: Request) throws -> Future<String> {
        return try req.content.decode(TestModel.self).map({ (model) -> (String) in
            return "您请求的参数是：\(model.test)"
        })
    }
}
