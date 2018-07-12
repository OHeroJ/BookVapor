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

        tokenAuthGroup.get("menu", "list", use: getMenuList)
        tokenAuthGroup.post(Menu.self, at:"menu", "add", use: createMenu)
        tokenAuthGroup.post(MenuContainer.self, at: "menu", "delete", use: deleteMenu)
    }
}

extension SysRouteController {

    func deleteMenu(_ request: Request, container: MenuContainer) throws -> Future<Response> {
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

    func createMenu(_ request: Request, menu: Menu) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        return Menu
            .query(on: request)
            .filter(\Menu.name == menu.name)
            .first()
            .flatMap { exisMenu in
                guard let _ = exisMenu  else {
                    return try request.makeErrorJson(message: "Menu 已经存在")
                }
                return try menu.save(on: request).makeJsonResponse(on: request)
            }
    }

    func getMenuList(_ request: Request) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        return try Menu
            .query(on: request)
            .all()
            .map{ menus in
                return self.createTree(parentId: 0, originArray: menus)
            }.makeJsonResponse(on: request)
    }
}

extension SysRouteController  {
    func createTree(parentId: Menu.ID, originArray: [Menu]) -> [Menu.Public] {
        let firstParents = originArray.filter({ $0.parentId == parentId})
        let originArr = Array(originArray.drop(while: {$0.parentId == parentId}))
        if (firstParents.count > 0) {
            return firstParents.map { (menu) ->  Menu.Public in
                return menu.convertToPublic(childrens: createTree(parentId: menu.id!, originArray: originArr))
            }
        } else {
            return []
        }
    }
}




