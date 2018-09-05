//
//  NewPasswordContainer.swift
//  App
//
//  Created by laijihua on 2018/6/25.
//

import Vapor

struct NewsPasswordContainer: Content {
    let email: String
    let password: String
    let newPassword: String
    let code: String
}
