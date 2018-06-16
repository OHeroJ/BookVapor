//
//  AuthenticationRouteController.swift
//  App
//
//  Created by laijihua on 2018/6/16.
//

import Foundation
import Vapor
import Crypto
import Authentication

final class AuthenticationRouteController: RouteCollection {

    private let authController = AuthenticationController()

    func boot(router: Router) throws {
        let group = router.grouped("api", "token").grouped(ApiErrorMiddleware.self)
        group.post(RefreshTokenContainer.self, at: "refresh", use: refreshAccessTokenHandler)

        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCrypt)
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let basicAuthGroup = group.grouped([basicAuthMiddleware, guardAuthMiddleware])
        basicAuthGroup.post(UserEmailContainer.self, at: "revoke", use: accessTokenRevocationhandler)
    }
}

//MARK: Helper
extension AuthenticationRouteController {
    func refreshAccessTokenHandler(_ request: Request, container: RefreshTokenContainer) throws -> Future<AuthenticationContainer> {
        return try authController.authenticationContainer(for: container.refreshToken, on: request)
    }

    func accessTokenRevocationhandler(_ request: Request, container: UserEmailContainer) throws -> Future<HTTPResponseStatus> {
        return try authController.revokeTokens(forEmail: container.email, on: request).transform(to: .noContent)
    }
}
