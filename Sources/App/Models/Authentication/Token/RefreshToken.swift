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

    init(userId: Int) throws {
        self.token = try CryptoRandom().generateData(count: 32).base64URLEncodedString()
        self.userId = userId
    }
}



extension RefreshToken: MySQLModel {}
extension RefreshToken: Migration {}





