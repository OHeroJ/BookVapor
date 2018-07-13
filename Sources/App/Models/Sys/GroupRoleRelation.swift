//
//  GroupRoleRelation.swift
//  APIErrorMiddleware
//
//  Created by laijihua on 2018/7/12.
//

import Vapor
import FluentPostgreSQL

// 组角色表
final class GroupRole: PostgreSQLPivot {
    var id: Int?
    var groupId: Group.ID
    var roleId: Role.ID

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?

    typealias Left = Group
    typealias Right = Role

    static var leftIDKey: LeftIDKey = \.groupId
    static var rightIDKey: RightIDKey = \.roleId

    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(groupId: Group.ID, roleId: Role.ID) {
        self.groupId = groupId
        self.roleId = roleId
    }
}

extension GroupRole: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.roleId, to: \Role.id)
            builder.reference(from: \.groupId, to: \Group.id)
        }
    }
}


