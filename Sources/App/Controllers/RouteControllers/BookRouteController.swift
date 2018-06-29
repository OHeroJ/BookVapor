//
//  BookController.swift
//  App
//
//  Created by laijihua on 2018/6/27.
//

import Vapor
import FluentPostgreSQL

final class BookRouteController: RouteCollection {
    func boot(router: Router) throws {
        let group = router.grouped("api", "book")

        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let authGroup = group.grouped([tokenAuthMiddleware, guardAuthMiddleware])
        authGroup.post(BookCreateContainer.self, at:"create", use: createBookHandler)

//        group.get("list", use: listBooksHandle)
    }
}

extension BookRouteController {
//    func listBooksHandle(_ request: Request) throws -> Future<JSONContainer<[Book]>>  {
//
//    }

    func createBookHandler(_ request: Request, container: BookCreateContainer) throws -> Future<JSONContainer<Book>> {
        let user = try request.requireAuthenticated(User.self)
        guard let userId = user.id else {
            throw Abort(.badRequest, reason: "认证失败", identifier: nil)
        }
        let book = Book(isbn: container.isbn,
                        name: container.name,
                        author: container.author,
                        price: container.price,
                        detail: container.detail,
                        covers: container.convers,
                        repCount: 0,
                        comCount: 0,
                        collCount: 0,
                        state: Book.State.check,
                        doubanPrice: container.doubanPrice,
                        doubanGrade: container.doubanGrade,
                        createId: userId,
                        classifyId: container.classifyId,
                        priceUintId: container.priceUintId)
        return book.create(on:request).convertToCustomContainer()
    }
}



