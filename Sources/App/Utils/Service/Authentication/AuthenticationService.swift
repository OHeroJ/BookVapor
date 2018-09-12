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


final class AuthenticationService {

    //MARK: Actions
    func authenticationContainer(for refreshToken: RefreshToken.Token, on connection: Request) throws -> Future<Response> {
        return try existingUser(matchingTokenString: refreshToken, on: connection)
            .unwrap(or: ApiError(code: .userNotExist))
            .flatMap { user in
            return try self.authenticationContainer(for: user.requireID(), on: connection)
        }
    }

    func authenticationContainer(for userId: User.ID, on connection: Request) throws -> Future<Response> {
        return try removeAllTokens(for: userId, on: connection)
            .flatMap { _ in
            return try map(to: AuthenticationContainer.self,
                           self.accessToken(for: userId, on: connection),
                           self.refreshToken(for: userId, on: connection)) { access, refresh in
                return AuthenticationContainer(accessToken: access, refreshToken: refresh)
                }.makeJson(on: connection)
        }
    }

    func revokeTokens(forEmail email: String, on connection: DatabaseConnectable) throws -> Future<Void> {
        return User
            .query(on: connection)
            .filter(\.email == email)
            .first()
            .flatMap { user in
            guard let user = user else { return Future.map(on: connection) { Void() } }
            return try self.removeAllTokens(for: user.requireID(), on: connection)
        }
    }
}

//MARK: Helper
private extension AuthenticationService {

    //MARK: Queries
    func existingUser(matchingTokenString tokenString: RefreshToken.Token, on connection: DatabaseConnectable) throws -> Future<User?> {
        return RefreshToken
            .query(on: connection)
            .filter(\RefreshToken.token == tokenString)
            .first()
            .unwrap(or: ApiError(code: .refreshTokenNotExist))
            .flatMap { token in
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
    func removeAllTokens(for userId: User.ID?, on connection: DatabaseConnectable) throws -> Future<Void> {
        guard let userId = userId else { throw ApiError(code: .userNotExist) }

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
    func accessToken(for userId: User.ID, on connection: DatabaseConnectable) throws -> Future<AccessToken> {
        return try AccessToken(userId: userId)
            .save(on: connection)
    }

    func refreshToken(for userId: User.ID, on connection: DatabaseConnectable) throws -> Future<RefreshToken> {
        return try RefreshToken(userId: userId)
            .save(on: connection)
    }

    func accessToken(for refreshToken: RefreshToken, on connection: DatabaseConnectable) throws -> Future<AccessToken> {
        return try AccessToken(userId: refreshToken.userId)
            .save(on: connection)
    }
}
