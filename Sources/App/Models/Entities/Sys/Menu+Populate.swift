//
//  Menu+Populate.swift
//  App
//
//  Created by laijihua on 2018/9/4.
//

import Vapor
import FluentPostgreSQL

/// 数据填充
final class PopulateMenuForms: Migration {
    typealias Database = PostgreSQLDatabase

    static var menus = [
        (name: "菜单管理", href: "/sys/menuList"),
        (name: "权限管理", href: "/sys/roleList"),
        (name: "用户管理", href: "/sys/userList"),
        (name: "资源管理", href: "/sys/resource")
    ]

    static func getHeadId(on connection: PostgreSQLConnection) -> Future<Menu.ID> {
        let sysMenu = Menu(sort: 0, name: "系统管理", href: "/sys/menuList", icon: "", isShow: true)
        return sysMenu.create(on: connection).map {return $0.id! }
    }

    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {

        return getHeadId(on: conn)
            .flatMap(to: Void.self) { headId in
                let fetures = menus.map { touple -> EventLoopFuture<Void> in
                    let name = touple.0
                    let path = touple.href
                    return Menu(sort: 0, name: name, href: path, icon: "", isShow: true, parentId: headId)
                        .create(on: conn).map(to: Void.self, {_ in return})
                }
                return Future<Void>.andAll(fetures, eventLoop: conn.eventLoop)
        }
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        let futures = menus.map { menu in
            return Menu.query(on: conn).filter(\Menu.name == menu.name).delete()
        }
        return Future<Void>.andAll(futures, eventLoop: conn.eventLoop)
    }

}
