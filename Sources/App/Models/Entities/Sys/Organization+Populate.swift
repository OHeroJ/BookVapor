//
//  Organization+Populate.swift
//  App
//
//  Created by laijihua on 2018/8/30.
//

import Vapor
import FluentPostgreSQL

/// 数据填充
final class PopulateOrganizationForms: Migration {
    typealias Database = PostgreSQLDatabase

    static let organizations = [
        "再书"
    ]

    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        let futures = organizations.map { name in
            return Organization(parentId: 0, name: name, remarks: name).create(on: conn).map(to: Void.self, { _  in
                return
            })
        }
        return Future<Void>.andAll(futures, eventLoop: conn.eventLoop)
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        let futures = organizations.map { name in
            return Organization.query(on: conn).filter(\.name == name).delete()
        }
        return Future<Void>.andAll(futures, eventLoop: conn.eventLoop)
    }

}
