//
//  UserRoleRelation.swift
//  APIErrorMiddleware
//
//  Created by laijihua on 2018/7/12.
//

import Vapor
import FluentPostgreSQL

// 用户角色表
final class UserRole: PostgreSQLPivot {
    var id: Int?
    var userId: User.ID
    var roleId: Role.ID

    typealias Left = User
    typealias Right = Role

    static var leftIDKey: LeftIDKey = \.userId
    static var rightIDKey: RightIDKey = \.roleId

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?

    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(userId: User.ID, roleId: Role.ID) {
        self.userId = userId
        self.roleId = roleId
    }
}

extension UserRole: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userId, to: \User.id)
            builder.reference(from: \.roleId, to: \Role.id)
        }
    }
}

