//
//  WishBookComment.swift
//  App
//
//  Created by laijihua on 2018/6/23.
//

import Vapor
import FluentMySQL

/// 心愿书单评论
final class WishBookComment: Content {
    var id: Int?
    var wishBookId: WishBook.ID
    var userId: User.ID
    var comment: String
    var reportCount: Int

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }
}

extension WishBookComment: Migration {}
extension WishBookComment: MySQLModel {}

extension WishBookComment {
    var wishBook: Parent<WishBookComment, WishBook> {
        return parent(\.wishBookId)
    }
    
    var creater: Parent<WishBookComment, User> {
        return parent(\.userId)
    }
}
