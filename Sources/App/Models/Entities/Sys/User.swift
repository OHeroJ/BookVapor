//
//  User.swift
//  App
//
//  Created by laijihua on 2018/5/31.
//

import Vapor
import FluentPostgreSQL
import Authentication
import Pagination

/// 用户表
final class User: Content {
    var id: Int?
    var organizId: Organization.ID
    var phone: String?
    var wechat: String? // 微信账号
    var qq: String? // qq 账号
    var name: String
    var email: String
    var avator: String?
    var info: String?
    var password: String
    var delFlag: Bool?
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?

    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(name: String,
         phone: String? = nil,
         email: String,
         avator: String? = nil,
         password: String,
         delFlag: Bool = false,
         organizId: Organization.ID? = nil,
         info: String? = nil) {
        self.name = name
        self.phone = phone
        self.email = email
        self.avator = avator
        self.password = password
        self.delFlag = false
        self.organizId = organizId ?? 0
        self.info = info ?? "暂无简介"
    }
}

extension User: PostgreSQLModel {}
extension User: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.organizId, to: \Organization.id)
        }
    }
}

extension User {
    var publishedBooks: Children<User, Book> { // 发布的书
        return children(\.createId)
    }

    var codes: Children<User, ActiveCode> {
        return children(\.userId)
    }

    var collectedBooks: Siblings<User, Book, Collect> { // 收藏的书
        return siblings()
    }

    var organization: Parent<User, Organization> { // 组织
        return parent(\.organizId)
    }
}

// MARK:- Public
/// 对外的数据
extension User {
    final class Public: Content {
        var id: Int?
        var name: String
        var email: String
        var avator: String?
        var phone: String?
        var info: String?
        var qq: String?
        var wechat: String?

        init(id: Int?, name: String, email: String, avator: String?, phone: String?, info: String? = nil, qq: String? = nil, wechat: String? = nil) {
            self.id = id
            self.name = name
            self.email = email
            self.avator = avator
            self.phone = phone
            self.info = info
            self.qq = qq
            self.wechat = wechat
        }
    }

    func convertToPublic() -> Public {
        return User.Public(id: id, name: name, email: email, avator: avator, phone: phone, info: info, qq: qq, wechat: wechat)
    }
}

extension Future where T: User {
    func convertToPublic() -> Future<User.Public> {
        return self.map(to: User.Public.self, { user in
            return user.convertToPublic()
        })
    }
}

extension User: Paginatable {}

//MARK: BasicAuthenticatable
extension User: BasicAuthenticatable {
    static var usernameKey: WritableKeyPath<User, String> = \.email
    static var passwordKey: WritableKeyPath<User, String> = \.password
}

//MARK: TOkenAuthenticatable
extension User: TokenAuthenticatable {
    typealias TokenType = AccessToken
}

//MARK: Validatable
extension User: Validatable {
    static func validations() throws -> Validations<User> {
        var validations = Validations(User.self)
        try validations.add(\.email, .email)
        try validations.add(\.password, .password)
        return validations
    }
}
