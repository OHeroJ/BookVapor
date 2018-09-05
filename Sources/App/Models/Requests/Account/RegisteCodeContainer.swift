//
//  RegisteCodeContainer.swift
//  App
//
//  Created by laijihua on 2018/9/5.
//
import Vapor

struct RegisteCodeContainer: Content {
    var code: String
    var userId: User.ID
}
