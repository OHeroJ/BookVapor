//
//  AuthenticationContainer.swift
//  App
//
//  Created by laijihua on 2018/6/16.
//

import Vapor

struct AuthenticationContainer: Content {

    //MARK: Properties
    let accessToken: AccessToken.Token
    let expiresIn: TimeInterval
    let refreshToken: RefreshToken.Token

    //MARK: Initializers
    init(accessToken: AccessToken, refreshToken: RefreshToken) {
        self.accessToken = accessToken.token
        self.expiresIn = AccessToken.Const.expirationInterval //Not honored, just an estimate
        self.refreshToken = refreshToken.token
    }

    //MARK: Codable
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
    }
}
