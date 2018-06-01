//
//  ChatContent.swift
//  App
//
//  Created by laijihua on 2018/5/31.
//

import Vapor
import FluentMySQL

final class ChatContent: Content {
    var id: Int?

    var userId: Int
    var action: Int
    var content: String
    var createdAt: TimeInterval
    var updatedAt: TimeInterval?
    var deletedAt: TimeInterval?

    init(userId: Int, action: Int, content: String, createdAt: TimeInterval, updatedAt: TimeInterval?, deletedAt: TimeInterval?) {
        self.userId = userId
        self.action = action
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}

extension ChatContent: MySQLModel {}
extension ChatContent: Migration {}
