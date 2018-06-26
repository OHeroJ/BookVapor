//
//  ActiveCode.swift
//  App
//
//  Created by laijihua on 2018/6/23.
//

import Vapor
import FluentMySQL

/// 邮箱验证码

final class ActiveCode: Content {
    var id: Int?
    var userId: User.ID
    var state: Bool // 是否激活
    var code: String

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?

    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(userId: User.ID, code: String) {
        self.userId = userId
        self.code = code
        self.state = false
    }
}

extension ActiveCode: MySQLModel {}
extension ActiveCode: Migration {}

extension ActiveCode {
    var user: Parent<ActiveCode, User> {
        return parent(\.userId)
    }
}


