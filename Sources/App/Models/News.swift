//
//  News.swift
//  App
//
//  Created by laijihua on 2018/7/8.
//

import Vapor
import FluentPostgreSQL

final class News: Content {
    var id: Int?
    var type: Int
    var code: Int
    var message: String
    var title: String
    var senderName: String
    var senderPic: String
    var timeLine: String
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(type: Int,
         code: Int,
         message: String,
         title: String,
         senderName: String,
         senderPic: String,
         timeLine: String) {
        self.type = type
        self.code = code
        self.message = message
        self.title = title
        self.senderName = senderName
        self.senderPic = senderPic
        self.timeLine = timeLine
    }
}

extension News: Migration {}
extension News: PostgreSQLModel {}


