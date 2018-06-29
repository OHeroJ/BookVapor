//
//  AccountRouteController.swift
//  App
//
//  Created by laijihua on 2018/6/20.
//

import Vapor
import FluentPostgreSQL

final class AccountRouteController: RouteCollection {

    func boot(router: Router) throws {
        let group = router.grouped("api", "account")
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthMiddleware = User.tokenAuthMiddleware()

        let tokenAuthGroup = group.grouped([tokenAuthMiddleware, guardAuthMiddleware])

        tokenAuthGroup.get("info", use: getAcccountInfo)
    }
}

extension AccountRouteController {
    func getAcccountInfo(_ request: Request) throws -> JSONContainer<User.Public> {
        return try request
            .requireAuthenticated(User.self)
            .convertToPublic()
            .convertToSuccessContainer()
    }
}

