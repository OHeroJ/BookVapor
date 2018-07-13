//
//  Group.swift
//  APIErrorMiddleware
//
//  Created by laijihua on 2018/7/12.
//

import Vapor
import FluentPostgreSQL

/// 组表
final class Group: Content {
    var id: Int?
    var parentId: Group.ID
    var name: String
    var remarks: String?

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(parentId: Group.ID, name: String, remarks: String? = nil) {
        self.parentId = parentId
        self.name = name
        self.remarks = remarks
    }
}

extension Group: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.parentId, to: \Group.id)
        }
    }
}
extension Group: PostgreSQLModel {}

