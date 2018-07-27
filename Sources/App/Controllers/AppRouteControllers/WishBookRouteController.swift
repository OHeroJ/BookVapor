//
//  WishBookController.swift
//  App
//
//  Created by laijihua on 2018/6/27.
//

import Foundation

import Vapor
import FluentPostgreSQL

final class WishBookRouteController: RouteCollection {
    func boot(router: Router) throws {
        let group = router.grouped("api", "wishbook")
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let authGroup = group.grouped([tokenAuthMiddleware, guardAuthMiddleware])

        authGroup.post(WishBookCreateContainer.self, at:"create", use: createWishBook)
        authGroup.post(WishBookComment.self, at:"comment", use: commnetWishBook)

    }
}

extension WishBookRouteController {

    func commnetWishBook(_ request: Request, container: WishBookComment) throws -> Future<Response> {
        return try container.create(on: request).makeJsonResponse(on: request)
    }

    func createWishBook(_ request: Request, container: WishBookCreateContainer) throws -> Future<Response> {
        let wishBook = WishBook(title: container.title,
                                content: container.content,
                                userId: container.userId,
                                commentCount: 0)
        return try wishBook.save(on: request).makeJsonResponse(on: request)
    }

}
