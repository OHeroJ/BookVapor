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
        let group = router.grouped("api", "users").grouped(ApiErrorMiddleware.self)
        
        group.post(User.self, at: "login", use: loginUserHandler)
        group.post(User.self, at: "register", use: registerUserHandler)
    }
}

//MARK: Helper
private extension UserRouteController {

    func loginUserHandler(_ request: Request, user: User) throws -> Future<AuthenticationContainer> {
        return User
            .query(on: request)
            .filter(\.email == user.email)
            .first()
            .flatMap { existingUser in
                guard let existingUser = existingUser else {
                    throw Abort(.badRequest, reason: "this user does not exist" , identifier: "1")
                }
                let digest = try request.make(BCryptDigest.self)
                guard try digest.verify(user.password, created: existingUser.password) else {
                    throw Abort(.badRequest) /* authentication failure */
                }
                return try self.authController.authenticationContainer(for: existingUser, on: request)
        }
    }

    func registerUserHandler(_ request: Request, newUser: User) throws -> Future<AuthenticationContainer> {
        return User
            .query(on: request)
            .filter(\.email == newUser.email)
            .first()
            .flatMap { existingUser in
                guard existingUser == nil else {
                    throw Abort(.badRequest, reason: "a user with this email already exists" , identifier: "1")
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
        return User(name: name,
                    phone: phone,
                    email: email,
                    avator: avator,
                    password: password)
    }
}


