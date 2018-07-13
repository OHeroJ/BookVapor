//
//  UserRightRelation.swift
//  APIErrorMiddleware
//
//  Created by laijihua on 2018/7/12.
//

import Vapor
import FluentPostgreSQL

// 用户权限表
final class UserRight: PostgreSQLPivot {
    var id: Int?
    var userId: User.ID
    var rightId: Right.ID

    typealias Left = User
    typealias Right = App.Right

    static var leftIDKey: LeftIDKey = \.userId
    static var rightIDKey: RightIDKey = \.rightId

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?

    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(userId: User.ID, rightId: Right.ID) {
        self.userId = userId
        self.rightId = rightId
    }
}

extension UserRight: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userId, to: \User.id)
            builder.reference(from: \.rightId, to: \Right.id)
        }
    }
}

