//
//  GroupRightRelation.swift
//  APIErrorMiddleware
//
//  Created by laijihua on 2018/7/12.
//

import Vapor
import FluentPostgreSQL

/// 组权限表，为了方便多个操作， 该表可能呢不需要
final class GroupRight: PostgreSQLPivot {
    var id: Int?
    var groupId: Group.ID
    var rightId: Right.ID

    typealias Left = Group
    typealias Right = App.Right

    static var leftIDKey: LeftIDKey = \.groupId
    static var rightIDKey: RightIDKey = \.rightId

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?

    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(groupId: Group.ID, rightId: Right.ID) {
        self.groupId = groupId
        self.rightId = rightId
    }
}

extension GroupRight: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.groupId, to: \Group.id)
            builder.reference(from: \.rightId, to: \Right.id)
        }
    }
}

