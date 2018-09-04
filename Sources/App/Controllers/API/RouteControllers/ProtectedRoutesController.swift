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

        let basicAuthMiddleware = UserAuth.basicAuthMiddleware(using: BCrypt)
        let guardAuthMiddleware = UserAuth.guardAuthMiddleware()
        let basicAuthGroup = group.grouped([basicAuthMiddleware, guardAuthMiddleware])
        basicAuthGroup.get("basic", use: basicAuthRouteHandler)

        /// App 采用这个
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenAuthGroup = group.grouped([tokenAuthMiddleware, guardAuthMiddleware])
        tokenAuthGroup.get("token", use: tokenAuthRouteHandler)
    }
}

//MARK: Helper
private extension ProtectedRoutesController {

    /// 用 basic 获取用户信息
    func basicAuthRouteHandler(_ request: Request) throws -> Future<Response> {
        let user =  try request
            .requireAuthenticated(User.self)
        return try request.makeJson(response: JSONContainer(data: user))
    }

    /// 用 token 获取用户信息
    func tokenAuthRouteHandler(_ request: Request) throws -> Future<Response> {
        let user =  try request
            .requireAuthenticated(User.self)
        return try request.makeJson(response: JSONContainer(data: user))
    }
}



