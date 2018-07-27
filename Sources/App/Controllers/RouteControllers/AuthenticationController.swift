//
//  AuthenticationController.swift
//  App
//
//  Created by laijihua on 2018/6/16.
//

import Vapor
import Fluent
import FluentPostgreSQL
import Crypto

import SendGrid

final class AuthenticationController {

    //MARK: Actions
    func authenticationContainer(for refreshToken: RefreshToken.Token, on connection: Request) throws -> Future<Response> {
        return try existingUser(matchingTokenString: refreshToken, on: connection).flatMap { user in
            guard let user = user else { return try connection.makeErrorJson(message: "用户不存在")}
            return try self.authenticationContainer(for: user, on: connection)
        }
    }

    func authenticationContainer(for user: User, on connection: Request) throws -> Future<Response> {
        return try removeAllTokens(for: user, on: connection)
            .flatMap { _ in
            return try map(to: AuthenticationContainer.self,
                           self.accessToken(for: user, on: connection),
                           self.refreshToken(for: user, on: connection)) { access, refresh in
                return AuthenticationContainer(accessToken: access, refreshToken: refresh)
                }.flatMap { (author)  in
                    return try JSONContainer.init(data: author).encode(for: connection)
                }
        }
    }

    func revokeTokens(forEmail email: String, on connection: DatabaseConnectable) throws -> Future<Void> {
        return User
            .query(on: connection)
            .filter(\.email == email)
            .first()
            .flatMap { user in
            guard let user = user else { return Future.map(on: connection) { Void() } }
            return try self.removeAllTokens(for: user, on: connection)
        }
    }
}

//MARK: Helper
private extension AuthenticationController {

    //MARK: Queries
    func existingUser(matchingTokenString tokenString: RefreshToken.Token, on connection: DatabaseConnectable) throws -> Future<User?> {
        return RefreshToken
            .query(on: connection)
            .filter(\.token == tokenString)
            .first()
            .flatMap { token in

            guard let token = token else { throw Abort(.notFound /* token not found */) }
            return User
                .query(on: connection)
                .filter(\.id == token.userId)
                .first()
        }
    }

    func existingUser(matching user: User, on connection: DatabaseConnectable) throws -> Future<User?> {
        return User
            .query(on: connection)
            .filter(\.email == user.email)
            .first()
    }

    //MARK: Cleanup
    func removeAllTokens(for user: User, on connection: DatabaseConnectable) throws -> Future<Void> {
        guard let userId = user.id else { throw Abort(.notFound) }

        let accessTokens = AccessToken
            .query(on: connection)
            .filter(\.userId == userId)
            .delete()

        let refreshToken =  RefreshToken
            .query(on: connection)
            .filter(\.userId == userId)
            .delete()

        return map(to: Void.self, accessTokens, refreshToken) { _, _ in Void() }
    }

    //MARK: Generation
    func accessToken(for user: User, on connection: DatabaseConnectable) throws -> Future<AccessToken> {
        return try AccessToken(userId: user.requireID())
            .save(on: connection)
    }

    func refreshToken(for user: User, on connection: DatabaseConnectable) throws -> Future<RefreshToken> {
        return try RefreshToken(userId: user.requireID())
            .save(on: connection)
    }

    func accessToken(for refreshToken: RefreshToken, on connection: DatabaseConnectable) throws -> Future<AccessToken> {
        return try AccessToken(userId: refreshToken.userId)
            .save(on: connection)
    }
}
