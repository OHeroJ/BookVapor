//
//  Right.swift
//  APIErrorMiddleware
//
//  Created by laijihua on 2018/7/12.
//

import Vapor
import FluentPostgreSQL

// 权限表
final class Right: Content {
    var id: Int?
    var parentId: Right.ID
    var remarks: String?
    var name: String

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?

    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(parentId: Right.ID,
         remarks:String? = nil,
         name: String) {
        self.parentId = parentId
        self.remarks = remarks
        self.name = name
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
