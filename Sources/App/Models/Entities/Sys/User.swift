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
    var organizId: Organization.ID  // 公司
    var name: String
    var email: String?
    var avator: String?
    var info: String? // 简介

    var phone: String?
    var wechat: String? // 微信账号
    var qq: String? // qq 账号

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(name: String,
         phone: String? = nil,
         email: String? = nil,
         avator: String? = nil,
         organizId: Organization.ID? = nil,
         info: String? = nil) {
        self.name = name
        self.phone = phone
        self.email = email
        self.avator = avator
        self.organizId = organizId ?? 1
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

extension User: Paginatable {}


//MARK: TOkenAuthenticatable
extension User: TokenAuthenticatable {
    typealias TokenType = AccessToken
}

