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

        /// 发送修改密码验证码
        group.post(UserEmailContainer.self, at:"changePwdCode", use: sendPwdCode)

        /// 激活校验码
        group.get("activate", use: activeRegisteEmailCode)
    }
}

//MARK: Helper
private extension UserRouteController {
    // 激活注册校验码
    func activeRegisteEmailCode(_ request: Request) throws -> Future<Response> {
        // 获取到参数
        let filters = try request.query.decode(RegisteCodeContainer.self)
        return ActiveCode
            .query(on: request)
            .filter(\ActiveCode.codeType == ActiveCode.CodeType.activeAccount.rawValue)
            .filter(\ActiveCode.userId == filters.userId)
            .filter(\ActiveCode.code == filters.code)
            .first()
            .unwrap(or: ApiError(code: .modelNotExist))
            .flatMap { code in
                code.state = true
                return try code
                    .save(on: request)
                    .map(to: Void.self, {_ in return })
                    .makeJson(request: request)
            }
    }


    /// 发送修改密码的验证码
    func sendPwdCode(_ request: Request, container: UserEmailContainer) throws -> Future<Response> {
        return UserAuth
            .query(on: request)
            .filter(\.identityType == UserAuth.AuthType.email.rawValue)
            .filter(\.identifier == container.email)
            .first()
            .unwrap(or: ApiError(code: .modelNotExist))
            .flatMap { existAuth in
                let codeStr: String = try String.random(length: 4)
                let activeCode = ActiveCode(userId: existAuth.userId, code: codeStr, type: .changePwd)
                return try activeCode
                    .create(on: request)
                    .flatMap {acode in
                        let content = EmailSender.Content.changePwd(emailTo: container.email, code: codeStr)
                        return try self.sendMail(request: request, content: content)
                    }.makeJson(request: request)
            }

    }

    func loginUserHandler(_ request: Request, container: EmailLoginContainer) throws -> Future<Response> {
        return UserAuth
            .query(on: request)
            .filter(\UserAuth.identityType == UserAuth.AuthType.email.rawValue)
            .filter(\UserAuth.identifier == container.email)
            .first()
            .unwrap(or: ApiError(code: .modelNotExist))
            .flatMap { existingAuth in
                let digest = try request.make(BCryptDigest.self)
                guard try digest.verify(container.password, created: existingAuth.credential) else {
                    throw ApiError(code: .authFail)
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
            .unwrap(or: ApiError(code: .modelNotExist))
            .flatMap{ userAuth in
                return userAuth
                    .user
                    .query(on: request)
                    .first()
                    .unwrap(or: ApiError(code: .modelNotExist))
                    .flatMap { user in
                        return try user
                            .codes
                            .query(on: request)
                            .filter(\ActiveCode.codeType == ActiveCode.CodeType.changePwd.rawValue)
                            .filter(\ActiveCode.code == container.code)
                            .first()
                            .flatMap { code in
                                // 只有激活的用户才可以修改密码
                                guard let code = code, code.state else {
                                    throw ApiError(code: .codeFail)
                                }
                                var tmpUserAuth = userAuth
                                tmpUserAuth.credential = container.password
                                return try tmpUserAuth
                                    .userAuth(with: request.make(BCryptDigest.self))
                                    .save(on: request)
                                    .map(to: Void.self, {_ in return })
                                    .makeJson(request: request)
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
                    throw ApiError(code: .modelExisted)
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
                                return try self.sendRegisteMail(user: user, request: request)
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


