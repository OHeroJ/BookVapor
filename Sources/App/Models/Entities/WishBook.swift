//
//  WishBook.swift
//  App
//
//  Created by laijihua on 2018/6/23.
//

import Vapor
import FluentPostgreSQL

/// 心愿书单
final class WishBook: Content {
    var id: Int?
    var title: String
    var content: String  //> 评论内容
    var userId: User.ID
    var commentCount: Int //> 评论数

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?

    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(title: String, content: String, userId: User.ID, commentCount: Int = 0) {
        self.title = title
        self.content = content
        self.userId = userId
        self.commentCount = commentCount
    }
}

extension WishBook: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userId, to: \User.id)
        }
    }
}
extension WishBook: PostgreSQLModel {}




