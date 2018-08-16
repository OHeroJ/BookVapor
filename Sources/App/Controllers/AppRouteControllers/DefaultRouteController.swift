//
//  DefaultRouteController.swift
//  App
//
//  Created by laijihua on 2018/7/14.
//

import Vapor
import FluentPostgreSQL

/// 默认数据填充的路由
final class DefaultRouteController: RouteCollection {
    func boot(router: Router) throws {
        router.post("api","db","default", use: defaultConfigDb)
    }
}

extension DefaultRouteController {
    func defaultConfigDb(_ request: Request) throws -> Future<Response> {
        let sysMenu = Menu(sort: 0, name: "系统管理", href: "/sys/menuList", icon: "", isShow: true)
        let menuMenu = Menu(sort: 0, name: "菜单管理", href: "/sys/menuList", icon: "", isShow: true)
        let roleMenu = Menu(sort: 0, name: "权限管理", href: "/sys/roleList", icon: "", isShow: true)
        let userMenu = Menu(sort: 0, name: "用户管理", href: "/sys/userList", icon: "", isShow: true)
        let sourceMenu = Menu(sort: 0, name: "资源管理", href: "/sys/resource", icon: "", isShow: true)

        _ = sysMenu.save(on: request)
        _ = menuMenu.save(on: request)
        _ = roleMenu.save(on: request)
        _ = userMenu.save(on: request)
        _ = sourceMenu.save(on: request)

        return try request.makeVoidJson()
    }
}

