//
//  PriceUnit.swift
//  App
//
//  Created by laijihua on 2018/6/23.
//

import Vapor
import FluentMySQL

final class PriceUnit: Content {
    var id: Int?
    var unit: String // 单位名字

    init(unit: String) {
        self.unit = unit
    }
}

extension PriceUnit: Migration {}
extension PriceUnit: MySQLModel {}

extension PriceUnit {
    var books: Children<PriceUnit, Book> {
        return children(\Book.priceUintId)
    }
}


