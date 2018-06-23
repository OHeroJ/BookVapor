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
    var userId: User.ID
    var friendId: User.ID

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?

    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(userId: User.ID, friendId: User.ID) {
        self.userId = userId
        self.friendId = friendId
    }
}

extension Friend: MySQLModel {}
extension Friend: Migration {}
