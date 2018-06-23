//
//  Book.swift
//  App
//
//  Created by laijihua on 2018/6/22.
//

import Vapor
import FluentMySQL

final class Book: Content {
    var id:Int?
    var covers: [String]
    var name: String
    var isbn: String
    var author: String
    var price: Double
    var detail: String
    var commentCount: Int
    var collectCount: Int
    var reportCount: Int
    var state: State
    var doubanPrice: Double
    var doubanGrade: Double // 豆瓣评分

    var createId: User.ID // 创建者 id 多-1
    var classifyId: BookClassify.ID // 分类 id  多-1
    var priceUintId: PriceUnit.ID // 货币 id  多对1 

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?

    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(isbn: String,
         name: String,
         author: String,
         price: Double,
         detail: String,
         covers: [String],
         repCount: Int,
         comCount: Int,
         collCount: Int,
         state: Book.State,
         doubanPrice: Double,
         doubanGrade: Double,
         createId: User.ID,
         classifyId: BookClassify.ID,
         priceUintId: PriceUnit.ID) {
        self.author = author
        self.isbn = isbn
        self.name = name
        self.price = price
        self.detail = detail
        self.covers = covers
        self.commentCount = comCount
        self.collectCount = collCount
        self.state = state
        self.doubanPrice = doubanPrice
        self.doubanGrade = doubanGrade
        self.createId = createId
        self.classifyId = classifyId
        self.priceUintId = priceUintId
        self.reportCount = repCount
    }
}

extension Book {
    var creator:Parent<Book, User> { // 多 - 1
        return parent(\.createId)
    }

    var classify:Parent<Book, BookClassify> {
        return parent(\.classifyId)
    }

    var unit:Parent<Book, PriceUnit> {
        return parent(\.priceUintId)
    }
}

extension Book {
    enum State: Int, Codable {
        case check = 0 // 审核状态
        case putaway = 1 // 发布状态
        case soldout = 2 // 下架
        case deleted = 3 // 删除 
    }
}

extension Book: MySQLModel {}
extension Book: Migration {

//    static func prepare(on connection: MySQLConnection) -> Future<Void> {
//        return Database.create(self, on: connection) { builder in
//            try addProperties(to: builder)
//            builder.reference(from: \.createId, to: \User.id)
//            builder.reference(from: \.classifyId, to: \BookClassify.id)
//            builder.reference(from: \.priceUintId, to: \PriceUnit.id)
//        }
//    }
}



