//
//  DefaultRouteController.swift
//  App
//
//  Created by laijihua on 2018/7/14.
//

import Vapor
import FluentPostgreSQL

/// 默认数据填充的路由
final class DefaultRouteController: RouteCollection {
    func boot(router: Router) throws {
        router.post("api","db","default", use: defaultConfigDb)
    }
}

extension DefaultRouteController {
    func defaultConfigDb(_ request: Request) throws -> Future<Response> {
        let rootRole = Role(parentId: 0, sort: 0, name: "根")
        rootRole.id = 0
        _ = rootRole.create(on: request)

        let defaultRole = Role(parentId: 0, sort: 0, name: "客户")
        _ = defaultRole.create(on: request)

        let rootRight = Right(parentId: 0, name: "根")
        rootRight.id = 0
        _ = rootRight.create(on: request)

        let defaultRight = Right(parentId: 0, name: "修改")
        _ = defaultRight.create(on: request)

        return try request.makeJson(response:JSONContainer<Empty>.successEmpty)
    }
}

