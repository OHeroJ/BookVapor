//
//  Notify.swift
//  App
//
//  Created by laijihua on 2018/8/27.
//

import Vapor
import FluentPostgreSQL

final class Notify: Content {
    var id: Int?
    var content: String?
    var type: Int // 消息的类型，1: 公告 Announce，2: 提醒 Remind，3：信息 Message
    var target: Int?
    var targetType: String?
    var action: String?
    var sender: User.ID?

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(type: Int,
         target:Int? = nil,
         targetType: String? = nil,
         action: String? = nil,
         sender: User.ID? = nil,
         content: String? = nil){
        self.type = type
        self.target = target
        self.targetType = targetType
        self.action = action
        self.sender = sender
        self.content = content
    }
}

extension Notify: Migration {}
extension Notify: PostgreSQLModel {}



