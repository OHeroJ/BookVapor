//
//  Role.swift
//  App
//
//  Created by laijihua on 2018/7/10.
//

import Vapor
import FluentPostgreSQL

/// 角色表

final class Role: Content {
    var id: Int?
    var delFlag: Bool
    var parentId: Role.ID
    var sort: Int
    var name: String
    var remaks: String?
    var usable: Bool
    
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?

    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(parentId: Role.ID,
         sort: Int,
         name:String,
         remarks: String? = nil,
         usable: Bool = true,
         delFlag: Bool = false) {
        self.parentId = parentId
        self.sort = sort
        self.name = name
        self.remaks = remarks
        self.usable = usable
        self.delFlag = delFlag
    }
}

extension Role {
    struct Public: Content {
        var id: Int?
        var delFlag: Bool
        var parentId: Role.ID
        var sort: Int
        var name: String
        var remaks: String?
        var usable: Bool
        var children: [Public]
    }

    func convertToPublic(childrens: [Public]) -> Public {
        return Public(id: self.id,
                      delFlag: self.delFlag,
                      parentId: self.parentId,
                      sort: self.sort,
                      name: self.name,
                      remaks: self.remaks,
                      usable: self.usable,
                      children: childrens)
    }
}

extension Role: Migration {}
extension Role: PostgreSQLModel {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.parentId, to: \Role.id)
        }
    }
}
