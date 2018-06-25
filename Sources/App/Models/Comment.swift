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
}

extension Comment: Migration {}
extension Comment: MySQLModel {}

extension Comment {
    var book: Parent<Comment, Book> {
        return parent(\.bookId)
    }
    var creater: Parent<Comment, User> {
        return parent(\.userId)
    }
}
