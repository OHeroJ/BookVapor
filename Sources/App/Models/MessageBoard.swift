//
//  MessageBoard.swift
//  App
//
//  Created by laijihua on 2018/6/23.
//

import Vapor
import FluentPostgreSQL

// 用户留言板块
final class MessageBoard: Content {
    var id: Int?
    var content: String
    var userId: User.ID
    var senderId: User.ID

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?

    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(userId: User.ID, senderId: User.ID, content: String) {
        self.userId = userId
        self.senderId = senderId
        self.content = content
    }
}

extension MessageBoard: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userId, to: \User.id)
            builder.reference(from: \.senderId, to: \User.id)
        }
    }
}
extension MessageBoard: PostgreSQLModel {}
