//
//  UserRouteController.swift
//  App
//
//  Created by laijihua on 2018/6/16.
//

import Vapor
import Crypto
import FluentPostgreSQL
import SendGrid

final class UserRouteController: RouteCollection {
    private let authController = AuthenticationController()

    func boot(router: Router) throws {
        let group = router.grouped("api", "users")
        
        group.post(UserLoginContainer.self, at: "login", use: loginUserHandler)
        group.post(User.self, at: "register", use: registerUserHandler)

        /// 修改密码 
        group.post(NewsPasswordContainer.self, at:"newPassword", use: newPassword)
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

    // TODO: send email has some error , wait 
    func newPassword(_ request: Request, container: NewsPasswordContainer) throws -> Future<JSONContainer<NewsPasswordResponse>> {
        return User
            .query(on: request)
            .filter(\User.email == container.email)
            .first()
            .unwrap(or: Abort(.badRequest, reason: "No user found with email '\(container.email)'."))
            .flatMap(to: (ActiveCode, User).self) { user in
                return try user
                    .codes
                    .query(on: request)
                    .first()
                    .unwrap(or: Abort(.badRequest, reason: "No user found with ActiveCode '\(container.email)'.")).and(result: user)
            }.flatMap(to: JSONContainer<NewsPasswordResponse>.self) { code, user in
                guard code.state else {throw Abort(.badRequest, reason: "User not activated.")}
                user.password = container.newPassword
                return try user
                    .user(with: request.make(BCryptDigest.self))
                    .save(on: request)
                    .flatMap(to: User.self){ user in
                        return try self.sendMail(user: user, request: request).transform(to: user)
                    }
                    .transform(to: NewsPasswordResponse(status: "success"))
                    .convertToCustomContainer()
            }
    }

    func registerUserHandler(_ request: Request, newUser: User) throws -> Future<JSONContainer<AuthenticationContainer>> {
        return User
            .query(on: request)
            .filter(\.email == newUser.email)
            .first()
            .flatMap (to: User.self){ existingUser in
                guard existingUser == nil else {
                    throw Abort(.badRequest, reason: "This email is already registered.")
                }
                try newUser.validate()
                return try newUser
                    .user(with: request.make(BCryptDigest.self))
                    .save(on: request)
            }.flatMap(to: User.self) { user in
                return try self.sendMail(user: user, request: request)
                    .transform(to: user)
            }.flatMap { user in
                let logger = try request.make(Logger.self)
                logger.warning("New user created: \(user.email)")
                return try self.authController.authenticationContainer(for: user, on: request)
            }
        }
}

extension UserRouteController {
    func sendMail(user: User, request: Request) throws -> Future<Void> {
        let codeStr = try MD5.hash(Data(Date().description.utf8)).hexEncodedString().lowercased()
        let code = ActiveCode(userId: user.id!, code: codeStr)
        return code
            .save(on: request)
            .flatMap(to: Void.self) { (code)  in

            let promise = request.eventLoop.newPromise(Void.self)
            let scheme =  request.http.headers.firstValue(name: .host) ?? ""
            let url = "https://\(scheme)/api/users/activate/\(code.code)"

            let sendGridClient = try request.make(SendGridClient.self)
            let subject = "subjuect"
            let body = "body: 点击此链接激活\(url)"
            let from = EmailAddress(email: "oheroj@gmail.com", name: "twicebook")
            let address = EmailAddress(email: user.email, name: user.email)
            let header = Personalization(to: [address], subject: subject)
            let email = SendGridEmail(personalizations: [header], from: from, subject: subject, content: [[
                "type": "text",
                "value": body
            ]])

            DispatchQueue.global().async {
                let _ = try? sendGridClient.send([email], on: request)
                promise.succeed()
            }
            return promise.futureResult
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


