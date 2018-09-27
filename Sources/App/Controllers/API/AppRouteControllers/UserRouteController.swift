//
//  UserRouteController.swift
//  App
//
//  Created by laijihua on 2018/6/16.
//

import Vapor
import Crypto
import FluentPostgreSQL
import CNIOOpenSSL

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

        // 微信小程序
        // /oauth/token 通过小程序提供的验证信息获取服务器自己的 token
        group.post(UserWxAppOauthContainer.self, at: "/oauth/token", use: wxappOauthToken)
    }
}

//MARK: Helper
private extension UserRouteController {
    /// 小程序调用wx.login() 获取 临时登录凭证code ，并回传到开发者服务器。
    // 开发者服务器以code换取用户唯一标识openid 和 会话密钥session_key。
    func wxappOauthToken(_ request: Request, container: UserWxAppOauthContainer) throws -> Future<Response> {

        let appId = "wx295f34d030798e48"
        let secret = "39a549d066a34c56c8f1d34d606e3a95"
        let url = "https://api.weixin.qq.com/sns/jscode2session?appid=\(appId)&secret=\(secret)&js_code=\(container.code)&grant_type=authorization_code"
        return try request
            .make(Client.self)
            .get(url)
            .flatMap { response in
            guard let res = response.http.body.data else {
                throw ApiError(code:.custom)
            }
            let resContainer = try JSONDecoder().decode(WxAppCodeResContainer.self,from: res)
            let sessionKey = try resContainer.session_key.base64decode()
            let encryptedData = try container.encryptedData.base64decode()
            let iv = try container.iv.base64decode()

            let cipherAlgorithm = CipherAlgorithm(c: OpaquePointer(EVP_aes_128_cbc()))
            let shiper = Cipher(algorithm: cipherAlgorithm)

            let decrypted = try shiper.decrypt(encryptedData, key: sessionKey, iv: iv)
            let data = try JSONDecoder().decode(WxAppUserInfoContainer.self, from: decrypted)

            if data.watermark.appid == appId {
                /// 通过 resContainer.session_key 和 data.openid
                ///
                return UserAuth
                    .query(on: request)
                    .filter(\.identityType == UserAuth.AuthType.wxapp.rawValue)
                    .filter(\.identifier == data.openId)
                    .first()
                    .flatMap { userauth in
                        if let userAuth = userauth { // 该用户已授权过， 更新
                            var userAu = userAuth
                            let digest = try request.make(BCryptDigest.self)
                            userAu.credential = try digest.hash(resContainer.session_key)
                            return userAu
                                .update(on: request)
                                .flatMap { _ in
                                return try self.authService.authenticationContainer(for: userAuth.userId, on: request)
                            }
                        } else { // 注册
                            var userAuth = UserAuth(userId: nil, identityType: .wxapp, identifier: data.openId, credential: resContainer.session_key)
                            let newUser = User(name: data.nickName,
                                               avator: data.avatarUrl)
                            return newUser
                                .create(on: request)
                                .flatMap { user in
                                    userAuth.userId = try user.requireID()
                                    return try userAuth
                                        .userAuth(with: request.make(BCryptDigest.self))
                                        .create(on: request)
                                        .flatMap { _ in
                                            return try self.authService.authenticationContainer(for: user.requireID(), on: request)
                                    }
                            }
                        }
                }
            } else {
                throw ApiError(code: .custom)
            }
        }
    }

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


