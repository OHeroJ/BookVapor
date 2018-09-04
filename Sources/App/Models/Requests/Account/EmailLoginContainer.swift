
//
//  UserLoginContainer.swift
//  App
//
//  Created by laijihua on 2018/6/16.
//

import Vapor

struct EmailLoginContainer: Content {
    let email: String
    let password: String
}
