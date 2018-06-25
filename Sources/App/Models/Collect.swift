//
//  Collect.swift
//  App
//
//  Created by laijihua on 2018/6/23.
//

import Vapor
import FluentMySQL

/// 收藏表
final class Collect: MySQLPivot {
    var id: Int?
    var userId: User.ID
    var bookId: Book.ID

    typealias Left = User
    typealias Right = Book

    static let leftIDKey: LeftIDKey = \.userId
    static let rightIDKey: RightIDKey = \.bookId

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?

    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(userId: User.ID, bookId: Book.ID) {
        self.userId = userId
        self.bookId = bookId
    }

}

extension Collect: Migration {}

