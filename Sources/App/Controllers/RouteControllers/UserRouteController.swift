//
//  UserRouteController.swift
//  App
//
//  Created by laijihua on 2018/6/16.
//

import Vapor
import Crypto
import FluentMySQL

final class UserRouteController: RouteCollection {
    private let authController = AuthenticationController()

    func boot(router: Router) throws {
        let group = router.grouped("api", "users")
        
        group.post(UserLoginContainer.self, at: "login", use: loginUserHandler)
        group.post(User.self, at: "register", use: registerUserHandler)
    }
}

//MARK: Helper
private extension UserRouteController {

    func loginUserHandler(_ request: Request, user: UserLoginContainer) throws -> Future<JSONContainer<AuthenticationContainer>> {
        return User
            .query(on: request)
            .filter(\.email == user.email)
            .first()
            .flatMap { existingUser in
                guard let existingUser = existingUser else {
                    return request.future(JSONContainer<AuthenticationContainer>(code: 1, message: "不存在该用户"))
                }
                let digest = try request.make(BCryptDigest.self)
                guard try digest.verify(user.password, created: existingUser.password) else {
                     return request.future(JSONContainer<AuthenticationContainer>(code: 2, message: "认证失败")) /* authentication failure */
                }
                return try self.authController.authenticationContainer(for: existingUser, on: request)
            }
    }

    func registerUserHandler(_ request: Request, newUser: User) throws -> Future<JSONContainer<AuthenticationContainer>> {
        return User
            .query(on: request)
            .filter(\.email == newUser.email)
            .first()
            .flatMap { existingUser in
                guard existingUser == nil else {
                    return request.future(JSONContainer<AuthenticationContainer>(code: 1, message: "该用户已存在"))
                }
                try newUser.validate()
                return try newUser
                    .user(with: request.make(BCryptDigest.self))
                    .save(on: request)
                    .flatMap { user in
                        let logger = try request.make(Logger.self)
                        logger.warning("New user created: \(user.email)")
                        return try self.authController.authenticationContainer(for: user, on: request)
                    }
                }
        }
}

private extension User {
    func user(with digest: BCryptDigest) throws -> User {
        return try User(name: name,
                    phone: phone,
                    email: email,
                    avator: avator,
                    password: digest.hash(password))
    }
}


