//
//  RefreshTokenContainer.swift
//  App
//
//  Created by laijihua on 2018/6/16.
//

import Vapor

struct RefreshTokenContainer: Content {
    let refreshToken: RefreshToken.Token

    private enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}
