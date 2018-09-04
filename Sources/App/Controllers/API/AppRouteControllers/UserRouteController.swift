//
//  UserRouteController.swift
//  App
//
//  Created by laijihua on 2018/6/16.
//

import Vapor
import Crypto
import FluentPostgreSQL

final class UserRouteController: RouteCollection {
    private let authService = AuthenticationService()

    func boot(router: Router) throws {
        let group = router.grouped("api", "users")
        
        group.post(EmailLoginContainer.self, at: "login", use: loginUserHandler)
        group.post(UserRegisterContainer.self, at: "register", use: registerUserHandler)
        /// 修改密码 
        group.post(NewsPasswordContainer.self, at:"newPassword", use: newPassword)
    }
}

//MARK: Helper
private extension UserRouteController {
    func loginUserHandler(_ request: Request, container: EmailLoginContainer) throws -> Future<Response> {
        return UserAuth
            .query(on: request)
            .filter(\UserAuth.identityType == UserAuth.AuthType.email.rawValue)
            .filter(\UserAuth.identifier == container.email)
            .first()
            .flatMap { existingAuth in
                guard let existingAuth = existingAuth else {
                    return try request.makeJson(response: JSONContainer<Empty>.error(status: .userNotExist))
                }
                let digest = try request.make(BCryptDigest.self)
                guard try digest.verify(container.password, created: existingAuth.credential) else {
                    return try request.makeErrorJson(message: "认证失败")
                }
                return try self.authService.authenticationContainer(for: existingAuth.userId, on: request)
            }
    }

    // TODO: send email has some error , wait 
    func newPassword(_ request: Request, container: NewsPasswordContainer) throws -> Future<Response> {

        return UserAuth
            .query(on: request)
            .filter(\UserAuth.identityType == UserAuth.AuthType.email.rawValue)
            .filter(\UserAuth.identifier == container.email)
            .first()
            .flatMap{ userAuth in
                guard let userAuth = userAuth else {
                    return try request.makeErrorJson(message: "No user found with email '\(container.email)'.")
                }

                return userAuth
                    .user
                    .query(on: request)
                    .first()
                    .flatMap { user in
                        guard let user = user else {
                            return try request.makeErrorJson(message: "No user found with email '\(container.email)'.")
                        }
                        return try user
                            .codes
                            .query(on: request)
                            .first()
                            .flatMap { code in
                                // 只有激活的用户才可以修改密码
                                guard let code = code, code.state else {
                                    return try request.makeErrorJson(message: "邮箱未激活")
                                }
                                var tmpUserAuth = userAuth
                                tmpUserAuth.credential = container.password
                                return try tmpUserAuth
                                    .userAuth(with: request.make(BCryptDigest.self))
                                    .save(on: request)
                                    .map(to: Void.self, {_ in return })
                                    //                            .flatMap { user in
                                    //                                // 异步
                                    ////                                return try self.sendMail(user: user, request: request).transform(to: user)
                                    //                            }
                                    .makeVoidJson(request: request)
                        }
                    }

            }
    }

    func registerUserHandler(_ request: Request, container: UserRegisterContainer) throws -> Future<Response> {
        return UserAuth
            .query(on: request)
            .filter(\.identityType == UserAuth.AuthType.email.rawValue)
            .filter(\.identifier == container.email)
            .first()
            .flatMap{ existAuth in
                guard existAuth == nil else {
                    return try request.makeErrorJson(message: "This email is already registered.")
                }
                var userAuth = UserAuth(userId: nil, identityType: .email, identifier: container.email, credential: container.password)
                try userAuth.validate()
                let newUser = User(name: container.name,
                                   email: container.email,
                                   organizId: container.organizId)
                return newUser
                    .create(on: request)
                    .flatMap { user in
                        userAuth.userId = try user.requireID()
                        return try userAuth
                            .userAuth(with: request.make(BCryptDigest.self))
                            .create(on: request)
                            .flatMap { _ in
                                return try self.sendMail(user: user, request: request)
                            }.flatMap { _ in
                                return try self.authService.authenticationContainer(for: user.requireID(), on: request)
                            }
                    }
            }
        }
}

extension UserAuth {
    func userAuth(with digest: BCryptDigest) throws -> UserAuth {
        return try UserAuth(userId: userId, identityType: .type(identityType), identifier: identifier, credential: digest.hash(credential))
    }
}


