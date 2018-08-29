//
//  MenuRoleRelation.swift
//  App
//
//  Created by laijihua on 2018/7/16.
//

import Vapor
import FluentPostgreSQL

// 菜单权限表
final class MenuRole: PostgreSQLPivot  {
    var id: Int?
    var menuId: Menu.ID
    var roleId: Role.ID

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?

    typealias Left = Menu
    typealias Right = Role

    static var leftIDKey: LeftIDKey = \.menuId
    static var rightIDKey: RightIDKey = \.roleId

    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(menuId: Menu.ID, roleId: Role.ID) {
        self.menuId = menuId
        self.roleId = roleId
    }
}

extension MenuRole: Migration {

    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.menuId, to: \Menu.id)
            builder.reference(from: \.roleId, to: \Role.id)
        }
    }
}
