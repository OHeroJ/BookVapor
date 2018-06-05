//
//  User.swift
//  App
//
//  Created by laijihua on 2018/5/31.
//

import Vapor
import FluentMySQL

final class User: Content {
    var id: Int?
    
    var phone: String?
    var name: String
    var email: String
    var avator: String?
    var password: String
    var createdAt: TimeInterval
    var updatedAt: TimeInterval?
    var deletedAt: TimeInterval?

    init(name: String, phone: String?, email: String, avator: String?, password: String, createdAt: TimeInterval, updatedAt: TimeInterval?, deletedAt: TimeInterval?) {
        self.name = name
        self.phone = phone
        self.email = email
        self.avator = avator
        self.password = password
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}

extension User: MySQLModel {}
extension User: Migration {}



// MARK:- Public

/// 对外的数据
extension User {
    final class Public: Codable {
        var id: Int?
        var name: String
        var email: String
        var avator: String?
        var phone: String?

        init(id: Int?, name: String, email: String, avator: String?, phone: String?) {
            self.id = id
            self.name = name
            self.email = email
            self.avator = avator
            self.phone = phone
        }
    }

    func convertToPublic() -> Public {
        return User.Public(id: id, name: name, email: email, avator: avator, phone: phone)
    }
}

extension Future where T: User {
    func convertToPublic() -> Future<User.Public> {
        return self.map(to: User.Public.self, { user in
            return user.convertToPublic()
        })
    }
}
