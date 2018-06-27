//
//  Comment.swift
//  App
//
//  Created by laijihua on 2018/6/23.
//

import Vapor
import FluentMySQL

/// 评论表
final class Comment: Content {

    var id: Int?
    var bookId: Book.ID // 评论书籍 ID
    var userId: User.ID // 评论者
    var content: String
    var reportCount: Int

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?

    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(bookId: Book.ID, userId: User.ID, content: String, reportCount: Int) {
        self.bookId = bookId
        self.userId = userId
        self.content = content
        self.reportCount = reportCount
    }
}

extension Comment: Migration {
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userId, to: \User.id)
            builder.reference(from: \.bookId, to: \Book.id)
        }
    }
}
extension Comment: MySQLModel {}

extension Comment {
    var book: Parent<Comment, Book> {
        return parent(\.bookId)
    }
    var creater: Parent<Comment, User> {
        return parent(\.userId)
    }
}
