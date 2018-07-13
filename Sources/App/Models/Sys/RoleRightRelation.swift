//
//  RoleRightRelation.swift
//  APIErrorMiddleware
//
//  Created by laijihua on 2018/7/12.
//

import Vapor
import FluentPostgreSQL

/// 角色权限表
final class RoleRight: PostgreSQLPivot {

    var id: Int?
    var roleId: Role.ID
    var rightId: Right.ID

    typealias Left = Role
    typealias Right = App.Right

    static var leftIDKey: LeftIDKey = \.roleId
    static var rightIDKey: RightIDKey = \.rightId

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?

    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(roleId: Role.ID, rightId: Right.ID) {
        self.roleId = roleId
        self.rightId = rightId
    }
}

extension RoleRight: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.roleId, to: \Role.id)
            builder.reference(from: \.rightId, to: \Right.id)
        }
    }
}


