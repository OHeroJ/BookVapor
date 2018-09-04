//
//  databases.swift
//  App
//
//  Created by laijihua on 2018/8/29.
//

import Vapor
import FluentPostgreSQL
import Authentication

public func databases(config: inout DatabasesConfig, services: inout Services) throws {

    try services.register(FluentPostgreSQLProvider())
    try services.register(AuthenticationProvider())

    let psqlConfig = PostgreSQLDatabaseConfig(hostname: "localhost",
                                              port: 5432,
                                              username: "root",
                                              database: "book",
                                              password: "lai12345")
    config.add(database: PostgreSQLDatabase(config: psqlConfig), as: .psql)
}
