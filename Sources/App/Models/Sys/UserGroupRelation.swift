//
//  UserGroupRelation.swift
//  APIErrorMiddleware
//
//  Created by laijihua on 2018/7/12.
//

import Vapor
import FluentPostgreSQL

// 用户组表
final class UserGroup: PostgreSQLPivot {
    var id: Int?
    var userId: User.ID
    var groupId: Group.ID

    typealias Left = User
    typealias Right = Group

    static var leftIDKey: LeftIDKey = \.userId
    static var rightIDKey: RightIDKey = \.groupId

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?

    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(userId: User.ID, groupId: Group.ID) {
        self.userId = userId
        self.groupId = groupId
    }
}

extension UserGroup: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userId, to: \User.id)
            builder.reference(from: \.groupId, to: \Group.id)
        }
    }
}

