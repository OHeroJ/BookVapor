//
//  BookClassify.swift
//  App
//
//  Created by laijihua on 2018/6/23.
//

import Vapor
import FluentMySQL

final class BookClassify: Content {
    var id: Int?
    var name: String
    var parentId: BookClassify.ID
    var path: String

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?

    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(name: String, parentId: BookClassify.ID, path: String) {
        self.name = name
        self.parentId = parentId
        self.path = path
    }
}

extension BookClassify: Migration {}
extension BookClassify: MySQLModel {}

extension BookClassify {
    var books: Children<BookClassify, Book> {
        return children(\Book.classifyId)
    }
}
