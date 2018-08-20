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
    private let authController = AuthenticationController()

    func boot(router: Router) throws {
        let group = router.grouped("api", "users")
        
        group.post(UserLoginContainer.self, at: "login", use: loginUserHandler)
        group.post(UserRegisterContainer.self, at: "register", use: registerUserHandler)
        /// 修改密码 
        group.post(NewsPasswordContainer.self, at:"newPassword", use: newPassword)
    }
}

//MARK: Helper
private extension UserRouteController {
    func loginUserHandler(_ request: Request, user: UserLoginContainer) throws -> Future<Response> {
        return User
            .query(on: request)
            .filter(\.email == user.email)
            .first()
            .flatMap { existingUser in
                guard let existingUser = existingUser else {
                    return try request.makeJson(response: JSONContainer<Empty>.error(status: .userNotExist))
                }
                let digest = try request.make(BCryptDigest.self)
                guard try digest.verify(user.password, created: existingUser.password) else {
                    return try request.makeErrorJson(message: "认证失败")
                }
                return try self.authController.authenticationContainer(for: existingUser, on: request)
            }
    }

    // TODO: send email has some error , wait 
    func newPassword(_ request: Request, container: NewsPasswordContainer) throws -> Future<Response> {

        return User
            .query(on: request)
            .filter(\.email == container.email)
            .first()
            .flatMap{ user in
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
                            return try request.makeErrorJson(message: "User not activated.")
                        }
                        user.password = container.password
                        return try user.user(with: request.make(BCryptDigest.self))
                            .save(on: request)
//                            .flatMap { user in
//                                // 异步
////                                return try self.sendMail(user: user, request: request).transform(to: user)
//                            }
                            .makeJsonResponse(on: request)
                    }
            }
    }

    func registerUserHandler(_ request: Request, container: UserRegisterContainer) throws -> Future<Response> {
        return User
            .query(on: request)
            .filter(\.email == container.email)
            .first()
            .flatMap{ existingUser in
                guard existingUser == nil else {
                    return try request.makeErrorJson(message: "This email is already registered.")
                }
                let newUser = User(name: container.name,
                                   email: container.email,
                                   password: container.password,
                                   organizId: container.organizId)
                
                try newUser.validate()
                return try newUser
                    .user(with: request.make(BCryptDigest.self))
                    .create(on: request)
//                    .flatMap{ user in
//                        return try self.sendMail(user: user, request: request).transform(to: user)
//                    }
                    .flatMap { user in
                        return try self.authController.authenticationContainer(for: user, on: request)
                    }
            }
        }
}

extension RouteCollection {
    /*
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
    }*/
}

extension User {
    func user(with digest: BCryptDigest) throws -> User {
        return try User(name: name,
                    phone: phone,
                    email: email,
                    avator: avator,
                    password: digest.hash(password), organizId: 1)
    }
}


