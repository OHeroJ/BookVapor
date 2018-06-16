//
//  Friend.swift
//  App
//
//  Created by laijihua on 2018/5/31.
//

import Vapor
import FluentMySQL

final class Friend: Content {
    var id: Int?
    var userId: Int
    var friendId: Int

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?

    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(userId: Int, friendId: Int) {
        self.userId = userId
        self.friendId = friendId
    }
}

extension Friend: MySQLModel {}
extension Friend: Migration {}
