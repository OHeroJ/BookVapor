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
        tokenAuthGroup.post(Menu.self, at:"menu", use: createMenu)
    }
}

extension SysRouteController {

    func createMenu(_ request: Request, menu: Menu) throws -> Future<JSONContainer<Menu>> {
        let _ = try request.requireAuthenticated(User.self)
        return Menu
            .query(on: request)
            .filter(\Menu.name == menu.name)
            .first()
            .flatMap(to: Menu.self) { exisMenu in
                guard exisMenu == nil else {throw Abort(.badRequest, reason: "This menu is already exist")}
                return menu.save(on: request)
            }.convertToCustomContainer()
    }

    func getMenuList(_ request: Request) throws -> Future<JSONContainer<[Menu.Public]>> {
        let _ = try request.requireAuthenticated(User.self)
        return Menu
            .query(on: request)
            .all()
            .map{ menus in
                return self.createTree(parentId: 0, originArray: menus)
            }.convertToCustomContainer()
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




