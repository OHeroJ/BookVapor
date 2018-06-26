//
//  WishBook.swift
//  App
//
//  Created by laijihua on 2018/6/23.
//

import Vapor
import FluentMySQL

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
}

extension WishBook: Migration {}
extension WishBook: MySQLModel {}




