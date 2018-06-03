//
//  RequestSecurityMiddleware.swift
//  App
//
//  Created by laijihua on 2018/6/1.
//

import Vapor
import SwiftyJSON
import Crypto


private var secretKey = "1U23bn_&^%"

final class RequestNeedParam: Content {
    var _sign: String
    var _timestamp: TimeInterval
    var _desc: String // vapor 暂时获取不到请求的数据的字典形式

    init(sign: String, timestamp: TimeInterval, desc: String) {
        self._sign = sign
        self._timestamp = timestamp
        self._desc = desc
    }

    private func calculateSign() throws -> String {
        let sign = _desc + secretKey
        let md5 = Digest(algorithm: .md5)
        return try md5.hash(sign).hexEncodedString()
    }

    private var isSignValid: Bool {
        guard let sign = try? calculateSign() else {return false}
        return sign == _sign
    }

    private var isTimeValid: Bool {
        let timestamp = Date().timeIntervalSince1970
        return timestamp - _timestamp < 60
    }

    var isValid: Bool {
        return isSignValid && isTimeValid
    }
}

extension RequestNeedParam: CustomDebugStringConvertible {
    var debugDescription: String {
        return "_sign: \(_sign), _timestamp: \(_timestamp), _desc: \(_desc)"
    }
}


final class RequestSecurityMiddleware: Middleware, ServiceType {

    init() {}

    static func makeService(for worker: Container) throws -> RequestSecurityMiddleware {
        return .init()
    }

    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        switch request.http.method {
        case .GET:
            let params = try request.query.decode(RequestNeedParam.self)
            return try valideApiSecurity(params: params, next: next, request: request)
        default:
            return try request
                .content
                .decode(RequestNeedParam.self)
                .flatMap({ (param) -> EventLoopFuture<Response> in
                    return try self.valideApiSecurity(params: param, next: next, request: request)
                })
        }
    }

    private func valideApiSecurity(params: RequestNeedParam, next: Responder, request: Request) throws -> EventLoopFuture<Response> {
        if params.isValid {
            return try next.respond(to: request)
        } else {
            let res = ["code": "10086", "message": "参数错误"]
            let json = try JSONEncoder().encode(res)
            let httpResponse = HTTPResponse(
                status: .badRequest,
                headers: ["Content-Type": "application/json"],
                body: HTTPBody(data: json)
            )
            let response = Response(http: httpResponse, using: request.sharedContainer)
            return request.eventLoop.newSucceededFuture(result: response)
        }
    }
}
