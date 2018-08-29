//
//  Subscription.swift
//  App
//
//  Created by laijihua on 2018/8/27.
//
import Vapor
import FluentPostgreSQL

final class Subscription: Content {
    var id: Int?
    var target: Int
    var targetType: String
    var userId: User.ID
    var action: String

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(target: Int, targetType: String, userId: User.ID, action: String) {
        self.target = target
        self.targetType = targetType
        self.userId = userId
        self.action = action
    }
}

extension Subscription: Migration {}
extension Subscription: PostgreSQLModel {}
