//
//  UserAuth.swift
//  App
//
//  Created by laijihua on 2018/9/4.
//

import Vapor
import FluentPostgreSQL
import Crypto
import Authentication

/// 用该信息获取到 token
struct UserAuth: Content {
    var id: Int?
    var userId: User.ID
    var identityType: String // 登录类型
    var identifier: String // 标志 (手机号，邮箱，用户名或第三方应用的唯一标识)
    var credential: String // 密码凭证(站内的保存密码， 站外的不保存或保存 token)

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?

    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(userId: User.ID?, identityType: AuthType, identifier: String, credential: String) {
        self.userId = userId ?? 0
        self.identityType = identityType.rawValue
        self.identifier = identifier
        self.credential = credential
    }
}

extension UserAuth {
    enum AuthType: String {
        case email = "email"
        case wxapp = "wxapp" // 微信小程序

        static func type(_ val: String) -> AuthType {
            return AuthType(rawValue: val) ?? .email
        }
    }
}

extension UserAuth {
    var user: Parent<UserAuth, User> {
        return parent(\.userId)
    }
}

extension UserAuth: BasicAuthenticatable {
    static var usernameKey: WritableKeyPath<UserAuth, String> = \.identifier
    static var passwordKey: WritableKeyPath<UserAuth, String> = \.credential
}

extension UserAuth: PostgreSQLModel {}
extension UserAuth: Migration {}

extension UserAuth: Validatable {
    /// 只针对 email 的校验
    static func validations() throws -> Validations<UserAuth> {
        var validations = Validations(UserAuth.self)
        try validations.add(\.identifier, .email)
        try validations.add(\.credential, .password)
        return validations
    }
}
