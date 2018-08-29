//
//  Notify.swift
//  App
//
//  Created by laijihua on 2018/8/27.
//

import Vapor
import FluentPostgreSQL
import Pagination

final class Notify: Content {
    var id: Int?
    var content: String?
    var type: Int // 消息的类型，1: 公告 Announce，2: 提醒 Remind，3：信息 Message
    var target: Int?
    var targetType: String?
    var action: String?
    var senderId: User.ID?

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
        self.senderId = sender
        self.content = content
    }
}

extension Notify {
    static var announce: Int {return 1}
    static var remind: Int {return 2}
    static var message: Int {return 3}

    static var targetTypes: [String] {
        return ["topic", "reply", "comment"]
    }

    static var actionTypes: [String] {
        return ["like", "collect", "comment"]
    }
}

extension Notify {
    var userNotifis: Children<Notify,UserNotify> {
        return children(\UserNotify.notifyId)
    }
}

extension Notify: Paginatable {}
extension Notify: Migration {}
extension Notify: PostgreSQLModel {}



