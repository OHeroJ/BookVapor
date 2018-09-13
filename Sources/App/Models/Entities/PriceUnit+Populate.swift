//
//  PriceUnit+Populate.swift
//  App
//
//  Created by laijihua on 2018/9/13.
//

import Foundation

import Vapor
import FluentPostgreSQL

/// 数据填充
final class PopulatePriceUnitForms: Migration {
    typealias Database = PostgreSQLDatabase

    static let units = [
        "元",
        "美元"
    ]

    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        let futures = units.map { name in
            return PriceUnit(unit: name).create(on: conn).map(to: Void.self, { _  in
                return
            })
        }
        return Future<Void>.andAll(futures, eventLoop: conn.eventLoop)
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        let futures = units.map { name in
            return PriceUnit.query(on: conn).filter(\PriceUnit.unit == name).delete()
        }
        return Future<Void>.andAll(futures, eventLoop: conn.eventLoop)
    }

}
