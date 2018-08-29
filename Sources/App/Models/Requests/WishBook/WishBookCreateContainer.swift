//
//  WishBookCreateContainer.swift
//  App
//
//  Created by laijihua on 2018/7/17.
//

import Vapor

struct WishBookCreateContainer: Content {
    var title: String
    var content: String
    var userId: User.ID
}

