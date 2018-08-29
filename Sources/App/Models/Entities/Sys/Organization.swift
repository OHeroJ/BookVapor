//
//  Organization.swift
//  App
//
//  Created by laijihua on 2018/7/12.
//

import Vapor
import FluentPostgreSQL
// 组织表

final class Organization: Content {
    var id: Int?
    var parentId: Organization.ID
    var name: String
    var remarks: String?

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?

    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(parentId: Organization.ID, name: String, remarks: String?) {
        self.parentId = parentId
        self.name = name
        self.remarks = remarks
    }
}

extension Organization {
    var users: Children<Organization, User> {
        return children(\User.organizId)
    }
}

extension Organization: Migration {}
extension Organization: PostgreSQLModel {}
