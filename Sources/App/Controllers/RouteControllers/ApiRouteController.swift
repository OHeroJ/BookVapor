//
//  ApiController.swift
//  App
//
//  Created by laijihua on 2018/6/4.
//

import Vapor

final class ApiRouteController: RouteCollection {
    func boot(router: Router) throws {
        router.grouped("api")
            .grouped(ApiErrorMiddleware.self)
            .group(RequestSecurityMiddleware.self) { (apiRouter) in
                apiRouter.get("hello") { req in
                    return "hello"
                }
        }
    }
}
