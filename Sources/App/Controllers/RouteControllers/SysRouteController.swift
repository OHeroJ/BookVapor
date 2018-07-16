//
//  SysRouteController.swift
//  App
//
//  Created by laijihua on 2018/7/6.
//

import Foundation

import Vapor
import FluentPostgreSQL

final class SysRouteController: RouteCollection {
    func boot(router: Router) throws {
        let group = router.grouped("api", "sys")
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenAuthGroup = group.grouped([tokenAuthMiddleware, guardAuthMiddleware])

        let menuGroup = tokenAuthGroup.grouped("menu")
        menuGroup.get("list", use: getMenuList)
        menuGroup.post(Menu.self, at:"add", use: createMenu)
        menuGroup.post(DeleteIDContainer<Menu>.self, at:"delete", use: deleteMenu)

        let roleGroup = tokenAuthGroup.grouped("role") //
        roleGroup.post(Role.self, at: "add", use: createRole)
        roleGroup.post(DeleteIDContainer<Role>.self, at: "delete", use: deleteRole)
        roleGroup.get("list", use: getRoleList)

        let userGroup = group.grouped("user")
        userGroup.post(DeleteIDContainer<User>.self, at: "delete", use: deleteUser)

        let rightGroup = group.grouped("right")

    }
}

//MARK: - Right
extension SysRouteController {


}

//MARK: - User
extension SysRouteController {

    func deleteUser(_ request: Request, container: DeleteIDContainer<User>) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        return User
            .find(container.id, on: request)
            .flatMap { user in
                guard let tuser = user else {
                    return try request.makeErrorJson(message: "不存在")
                }
                return try tuser
                    .delete(on: request)
                    .makeVoidJson(request: request)
        }
    }
}

//MARK: - Role
extension SysRouteController {
    func createRole(_ request: Request, role: Role) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        return Role
            .query(on: request)
            .filter(\Role.id == role.id)
            .first()
            .flatMap { exisRole in
                guard exisRole == nil else {
                    return try request.makeErrorJson(message: "Menu 已经存在")
                }
                return try role.create(on: request).makeJsonResponse(on: request)
            }
    }

    func deleteRole(_ request: Request, container: DeleteIDContainer<Role>) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        return Role
            .find(container.id, on: request)
            .flatMap { role in
                guard let trole = role else {
                    return try request.makeErrorJson(message: "不存在")
                }
                return try trole
                    .delete(on: request)
                    .makeVoidJson(request: request)
        }
    }

    func getRoleList(_ request: Request) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        return try Role
            .query(on: request)
            .all()
            .map{ roles in
                return self.generateModelTree(parentId: 0, originArray: roles)
            }.makeJsonResponse(on: request)
    }

}

//MARK: - Menu
extension SysRouteController {

    func deleteMenu(_ request: Request, container: DeleteIDContainer<Menu>) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        return Menu
            .find(container.id, on: request)
            .flatMap { menu in
                guard let tmenu = menu else {
                    return try request.makeErrorJson(message: "不存在")
                }
                return try tmenu
                    .delete(on: request)
                    .makeVoidJson(request: request)
        }
    }

    /// 创建一个菜单代表一个新的功能注入， 那么也需要为其生成一个操作权限
    func createMenu(_ request: Request, menu: Menu) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        return Menu
            .query(on: request)
            .filter(\Menu.name == menu.name)
            .first()
            .flatMap { exisMenu in
                guard exisMenu == nil else {
                    return try request.makeErrorJson(message: "Menu 已经存在")
                }
                // menu&role
                return try menu.create(on: request).makeJsonResponse(on: request)
            }
    }

    func getMenuList(_ request: Request) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        return try Menu
            .query(on: request)
            .all()
            .map{ menus in
                return self.generateModelTree(parentId: 0, originArray: menus)
            }.makeJsonResponse(on: request)
    }
}





