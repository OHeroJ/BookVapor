//
//  UserWxAppOauthContainer.swift
//  App
//
//  Created by laijihua on 2018/9/10.
//
import Vapor

struct UserWxAppOauthContainer: Content {
    let encryptedData: String // encryptedData
    let iv: String // iv
    let code: String
}
