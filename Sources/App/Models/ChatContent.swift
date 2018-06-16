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

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?

    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(userId: Int, action: Int, content: String) {
        self.userId = userId
        self.action = action
        self.content = content
    }
}

extension ChatContent: MySQLModel {}
extension ChatContent: Migration {}
