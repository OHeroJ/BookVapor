//
//  ProtectedRoutesController.swift
//  App
//
//  Created by laijihua on 2018/6/16.
//

import Vapor
import Authentication

final class ProtectedRoutesController: RouteCollection {
    func boot(router: Router) throws {
        let group = router.grouped("api", "protected")

        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCrypt)
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let basicAuthGroup = group.grouped([basicAuthMiddleware, guardAuthMiddleware])
        basicAuthGroup.get("basic", use: basicAuthRouteHandler)


        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenAuthGroup = group.grouped([tokenAuthMiddleware, guardAuthMiddleware])
        tokenAuthGroup.get("token", use: tokenAuthRouteHandler)
    }
}

//MARK: Helper
private extension ProtectedRoutesController {

    func basicAuthRouteHandler(_ request: Request) throws -> User {
        return try request.requireAuthenticated(User.self)
    }

    func tokenAuthRouteHandler(_ request: Request) throws -> User {
        return try request.requireAuthenticated(User.self)
    }
}



