//
//  SysRouteController.swift
//  App
//
//  Created by laijihua on 2018/7/6.
//

import Foundation
import Crypto

import Vapor
import FluentPostgreSQL
import Pagination

final class SysRouteController: RouteCollection {

    private let authService = AuthenticationService()

    func boot(router: Router) throws {
        let group = router.grouped("api", "sys")
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenAuthGroup = group.grouped([tokenAuthMiddleware, guardAuthMiddleware])

        /// 菜单管理
        let menuGroup = tokenAuthGroup.grouped("menu")
        menuGroup.get("list", use: getMenuList)
        menuGroup.post(Menu.self, at:"add", use: createMenu)
        menuGroup.post(DeleteIDContainer<Menu>.self, at:"delete", use: deleteMenu)
        menuGroup.post(Menu.self, at:"update", use: updateMenu)

        /// 角色管理
        let roleGroup = tokenAuthGroup.grouped("role") //
        roleGroup.post(Role.self, at: "add", use: createRole)
        roleGroup.post(DeleteIDContainer<Role>.self, at: "delete", use: deleteRole)
        roleGroup.get("list", use: getRoleList)
        roleGroup.post(Role.self,at:"update", use: updateRole)

        /// 用户管理
        let userGroup = group.grouped("user")
        userGroup.post(DeleteIDContainer<User>.self, at: "delete", use: deleteUser)
        userGroup.get("page", use: listUser)
        userGroup.post(UserRegisterContainer.self,  at:"add", use: addUser)

        /// 权限(资源)管理
        let rightGroup = group.grouped("resource")
        rightGroup.get("list", use: listRight)
        rightGroup.post(Right.self,at:"update", use: updateRight)
        rightGroup.post(Right.self, at:"add", use: addRight)
        rightGroup.post(DeleteIDContainer<Right>.self, at:"delete", use: deleteRight)
    }
}

//MARK: - Right
extension SysRouteController {

    func updateRight(_ request: Request, container: Right) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        return Right
            .query(on: request)
            .filter(\.id == container.id)
            .first()
            .unwrap(or: ApiError(code: .modelNotExist))
            .flatMap { right in
                right.parentId = container.parentId
                right.name = container.name
                right.remarks = container.remarks
                right.code = container.code
                right.type = container.type
                return try right.update(on: request).makeJson(on: request)
        }
    }

    func addRight(_ request: Request, container: Right) throws -> Future<Response>  {
        let _ = try request.requireAuthenticated(User.self)
        return Right
            .query(on: request)
            .filter(\Right.name == container.name)
            .first()
            .flatMap { exisRole in
                guard exisRole == nil else {
                    throw ApiError(code: .modelExisted)
                }
                container.id = nil
                return try container.create(on: request).makeJson(on: request)
        }
    }

    func deleteRight(_ request: Request, container: DeleteIDContainer<Right>) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        return Right
            .find(container.id, on: request)
            .unwrap(or: ApiError(code: .modelNotExist))
            .flatMap { user in
                return try user
                    .delete(on: request)
                    .makeJson(request: request)
        }
    }

    func listRight(_ request: Request) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        return try Right
            .query(on: request)
            .paginate(for: request)
            .map {$0.response()}
            .makeJson(on: request)
    }

}

//MARK: - User
extension SysRouteController {
    func addUser(_ request: Request, container: UserRegisterContainer) throws -> Future<Response> {
        return UserAuth
            .query(on: request)
            .filter(\.identityType == UserAuth.AuthType.email.rawValue)
            .filter(\.identifier == container.email)
            .first()
            .flatMap{ existAuth in
                guard existAuth == nil else {
                    throw ApiError(code: .modelExisted)
                }

                var userAuth = UserAuth(userId: nil, identityType: .email, identifier: container.email, credential: container.password)
                try userAuth.validate()
                let newUser = User(name: container.name,
                                   email: container.email,
                                   organizId: container.organizId)

                return newUser
                    .create(on: request)
                    .flatMap { user in
                        userAuth.userId = try user.requireID()
                        return try userAuth
                            .userAuth(with: request.make(BCryptDigest.self))
                            .create(on: request)
                            .flatMap { _ in
                                return try self.sendRegisteMail(user: user, request: request)
                            }.flatMap { _ in
                                return try self.authService.authenticationContainer(for: user.requireID(), on: request)
                        }
                }
        }
    }

    func listUser(_ request: Request) throws -> Future<Response> {
        return try User
            .query(on: request)
            .paginate(for: request)
            .map {$0.response()}
            .makeJson(on: request)
    }

    func deleteUser(_ request: Request, container: DeleteIDContainer<User>) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        return User
            .find(container.id, on: request)
            .unwrap(or: ApiError(code: .modelNotExist))
            .flatMap { user in
                return try user
                    .delete(on: request)
                    .makeJson(request: request)
        }
    }
}

//MARK: - Role
extension SysRouteController {
    func updateRole(_ request: Request, container: Role) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        return Role
            .query(on: request)
            .filter(\.id == container.id)
            .first()
            .unwrap(or: ApiError(code: .modelNotExist))
            .flatMap { role in
                role.parentId = container.parentId
                role.name = container.name
                role.sort = container.sort
                role.usable = container.usable
                return try role.update(on: request).makeJson(on: request)
        }
    }

    func createRole(_ request: Request, role: Role) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        return Role
            .query(on: request)
            .filter(\Role.name == role.name)
            .first()
            .flatMap { exisRole in
                guard exisRole == nil else {
                    throw ApiError(code: .modelExisted)
                }
                role.id = nil
                return try role.create(on: request).makeJson(on: request)
            }
    }

    func deleteRole(_ request: Request, container: DeleteIDContainer<Role>) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        return Role
            .find(container.id, on: request)
            .unwrap(or: ApiError(code: .modelNotExist))
            .flatMap { role in
                return try role
                    .delete(on: request)
                    .makeJson(request: request)
        }
    }

    func getRoleList(_ request: Request) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        return try Role
            .query(on: request)
            .all()
            .map{ roles in
                return self.generateModelTree(parentId: 0, originArray: roles)
            }.makeJson(on: request)
    }

}

//MARK: - Menu
extension SysRouteController {

    func updateMenu(_ request: Request, container: Menu) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        return Menu
            .query(on: request)
            .filter(\.id == container.id)
            .first()
            .unwrap(or: ApiError(code: .modelNotExist))
            .flatMap { menu in
                menu.parentId = container.parentId
                menu.name = container.name
                menu.href = container.href
                menu.sort = container.sort
                menu.icon = container.icon
                menu.isShow = container.isShow
                return try menu.update(on: request).makeJson(on: request)
            }
    }

    func deleteMenu(_ request: Request, container: DeleteIDContainer<Menu>) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        return Menu
            .find(container.id, on: request)
            .unwrap(or: ApiError(code: .modelNotExist))
            .flatMap { menu in
                return try menu
                    .delete(on: request)
                    .makeJson(request: request)
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
                    throw ApiError(code: .modelExisted)
                }
                menu.id = nil;
                // menu&role
                return try menu.create(on: request).makeJson(on: request)
            }
    }

    func getMenuList(_ request: Request) throws -> Future<Response> {
        let _ = try request.requireAuthenticated(User.self)
        return try Menu
            .query(on: request)
            .all()
            .map{ menus in
                return self.generateModelTree(parentId: 0, originArray: menus)
            }.makeJson(on: request)
    }
}





