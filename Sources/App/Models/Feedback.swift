//
//  Feedback.swift
//  App
//
//  Created by laijihua on 2018/6/23.
//

import Vapor
import FluentPostgreSQL

/// 意见反馈

final class Feedback: Content {
    var id: Int?
    var content: String
    var userId: User.ID

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?

    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(userId: User.ID, content: String) {
        self.userId = userId
        self.content = content
    }
}

extension Feedback: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userId, to: \User.id)
        }
    }
}
extension Feedback: PostgreSQLModel {}

extension Feedback {
    var user: Parent<Feedback, User> {
        return parent(\.userId)
    }
}
