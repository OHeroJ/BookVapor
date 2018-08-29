//
//  UserRegisterContainer.swift
//  App
//
//  Created by laijihua on 2018/7/13.
//

import Foundation


import Vapor

struct UserRegisterContainer: Content {
    let email: String
    let password: String
    let name: String
    let organizId: Organization.ID?
}
