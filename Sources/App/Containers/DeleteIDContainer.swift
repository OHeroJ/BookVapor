//
//  DeleteIDContainer.swift
//  APIErrorMiddleware
//
//  Created by laijihua on 2018/7/15.
//


import Vapor
import FluentPostgreSQL

struct DeleteIDContainer<Model: PostgreSQLModel>: Content {
    var id: Model.ID
}
