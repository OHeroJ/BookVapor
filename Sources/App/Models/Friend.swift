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
    var createdAt: TimeInterval
    var updatedAt: TimeInterval?
    var deletedAt: TimeInterval?

    init(userId: Int, friendId: Int, createAt: TimeInterval, updatedAt: TimeInterval?, deletedAt: TimeInterval?) {
        self.userId = userId
        self.friendId = friendId
        self.createdAt = createAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}

extension Friend: MySQLModel {}
extension Friend: Migration {}
