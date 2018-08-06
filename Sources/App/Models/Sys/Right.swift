//
//  Right.swift
//  APIErrorMiddleware
//
//  Created by laijihua on 2018/7/12.
//

import Vapor
import FluentPostgreSQL
import Pagination

// 权限表
final class Right: Content {
    var id: Int?
    var parentId: Right.ID
    var remarks: String? // 备注
    var name: String
    var code: String // 代码
    var type: String // 类型 菜单 按钮 工能

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?

    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(parentId: Right.ID,
         remarks:String? = nil,
         name: String,
         code: String,
         type: String) {
        self.parentId = parentId
        self.remarks = remarks
        self.name = name
        self.code = code
        self.type = type
    }
}

extension Right: PostgreSQLModel {}
extension Right: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.parentId, to: \Right.id)
        }
    }
}

extension Right: Paginatable {}

