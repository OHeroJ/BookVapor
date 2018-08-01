//
//  Menu.swift
//  App
//
//  Created by laijihua on 2018/7/6.
//

import Vapor
import FluentPostgreSQL

final class Menu: Content {
    var id: Int?
    var parentId: Menu.ID
    var sort: Int // 第几个位置
    var name: String
    var href: String
    var icon: String
    var isShow: Bool

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?

    static var createdAtKey: TimestampKey? { return \.createdAt }
    static var updatedAtKey: TimestampKey? { return \.updatedAt }
    static var deletedAtKey: TimestampKey? { return \.deletedAt }

    init(sort: Int,
         name: String,
         href: String,
         icon: String,
         isShow: Bool,
         parentId: Int = 0) {
        self.sort = sort
        self.name = name
        self.href = href
        self.icon = icon
        self.isShow = isShow
        self.parentId = parentId
    }
}

extension Menu: ModelResusivable {

    struct Public: ModelPublicable {
        var id: Int?
        var parentId: Menu.ID
        var sort: Int // 第几个位置
        var name: String
        var href: String
        var icon: String
        var isShow: Bool
        var children: [Public]
    }

    func convertToPublic(childrens: [Public]) -> Public {
        return Public(id: self.id,
                      parentId: self.parentId,
                      sort: self.sort,
                      name: self.name,
                      href: self.href,
                      icon: self.icon,
                      isShow: self.isShow,
                      children: childrens)
    }
}

extension Menu {
    var children: Children<Menu, Menu>{
        return children(\Menu.parentId)
    }
}

extension Menu: PostgreSQLModel {}
extension Menu: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.parentId, to: \Menu.id)
        }
    }
}
