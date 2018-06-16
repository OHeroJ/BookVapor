//
//  RefreshToken.swift
//  App
//
//  Created by laijihua on 2018/6/15.
//

import Vapor
import FluentMySQL
import Crypto

struct RefreshToken: Content {
    typealias Token = String

    var id: Int?
    let token: Token
    let userId: Int

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?

    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(userId: Int) throws {
        self.token = try CryptoRandom().generateData(count: 32).base64URLEncodedString()
        self.userId = userId
    }
}



extension RefreshToken: MySQLModel {}
extension RefreshToken: Migration {}





