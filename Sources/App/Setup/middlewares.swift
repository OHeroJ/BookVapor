//
//  middlewares.swift
//  App
//
//  Created by laijihua on 2018/8/29.
//

import Vapor
import Authentication

public func middlewares(config: inout MiddlewareConfig, env: inout Environment) throws {

    config.use(APIErrorMiddleware(environment: env, specializations: [
        ModelNotFound()
    ]))

    let corsConfig = CORSMiddleware.Configuration(
        allowedOrigin: .originBased,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent],
        exposedHeaders: [
            HTTPHeaderName.authorization.description,
            HTTPHeaderName.contentLength.description,
            HTTPHeaderName.contentType.description,
            HTTPHeaderName.contentDisposition.description,
            HTTPHeaderName.cacheControl.description,
            HTTPHeaderName.expires.description
        ]
    )
    config.use(CORSMiddleware(configuration: corsConfig))
}
