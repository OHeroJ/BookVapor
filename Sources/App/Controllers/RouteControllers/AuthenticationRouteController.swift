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

// 由于access_token默认有效时间为一小时, 所以每隔一小时需要点击从而刷新令牌,就是使用refresh_token 换取了一个新的 access_token.
// 由于access_token默认有效时间为一小时, refreshToken 有效期为三年,所以需要先获取refreshToken, 然后将其保存, 以后每次就可以不用去阿里云认证就可以用 refreshToken 换取 AccessToken

final class AuthenticationRouteController: RouteCollection {

    private let authController = AuthenticationController()

    func boot(router: Router) throws {
        let group = router.grouped("api", "token")
        group.post(RefreshTokenContainer.self, at: "refresh", use: refreshAccessTokenHandler)

        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCrypt)
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let basicAuthGroup = group.grouped([basicAuthMiddleware, guardAuthMiddleware])
        basicAuthGroup.post(UserEmailContainer.self, at: "revoke", use: accessTokenRevocationhandler)
    }
}

//MARK: Helper
extension AuthenticationRouteController {
    func refreshAccessTokenHandler(_ request: Request, container: RefreshTokenContainer) throws -> Future<Response> {
        return try authController.authenticationContainer(for: container.refreshToken, on: request)
    }

    func accessTokenRevocationhandler(_ request: Request, container: UserEmailContainer) throws -> Future<HTTPResponseStatus> {
        return try authController.revokeTokens(forEmail: container.email, on: request).transform(to: .noContent)
    }
}
