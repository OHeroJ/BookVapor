//
//  UserUpdateContainer.swift
//  App
//
//  Created by laijihua on 2018/7/16.
//

import Vapor

struct UserUpdateContainer: Content {
    var organizId: Organization.ID?
    var phone: String?
    var name: String?
    var avator: String?
    var info: String?
}
