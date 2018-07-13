//
//  Log.swift
//  App
//
//  Created by laijihua on 2018/7/12.
//

import Vapor
import FluentPostgreSQL

// 操作日志表
final class OpLog: Content {
    var id: Int?
    var type: Int
    var content: String
    var userId: User.ID

    var createdAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }

    init(type:Int, content: String, userId: User.ID) {
        self.type = type
        self.content = content
        self.userId = userId
    }
}

extension OpLog {
    var user: Parent<OpLog, User> {
        return parent(\.userId)
    }
}

extension OpLog: Migration {

    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userId, to: \User.id)
        }
    }
}
extension OpLog: PostgreSQLModel {}
