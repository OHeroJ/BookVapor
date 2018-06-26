//
//  User.swift
//  App
//
//  Created by laijihua on 2018/5/31.
//

import Vapor
import FluentMySQL
import Authentication

final class User: Content {
    var id: Int?
    
    var phone: String?
    var name: String
    var email: String
    var avator: String?
    var password: String

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?

    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(name: String, phone: String?, email: String, avator: String?, password: String) {
        self.name = name
        self.phone = phone
        self.email = email
        self.avator = avator
        self.password = password
    }
}

extension User: MySQLModel {}
extension User: Migration {}

extension User {
    var publishedBooks: Children<User, Book> { // 发布的书
        return children(\.createId)
    }

    var codes: Children<User, ActiveCode> {
        return children(\.userId)
    }

    var collectedBooks: Siblings<User, Book, Collect> { // 收藏的书
        return siblings()
    }

}

// MARK:- Public
/// 对外的数据
extension User {
    final class Public: Content {
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


//MARK: BasicAuthenticatable
extension User: BasicAuthenticatable {
    static var usernameKey: WritableKeyPath<User, String> = \.email
    static var passwordKey: WritableKeyPath<User, String> = \.password
}

//MARK: TOkenAuthenticatable
extension User: TokenAuthenticatable {
    typealias TokenType = AccessToken
}

//MARK: Validatable
extension User: Validatable {
    static func validations() throws -> Validations<User> {
        var validations = Validations(User.self)
        try validations.add(\.email, .email)
        try validations.add(\.password, .password)
        return validations
    }
}






