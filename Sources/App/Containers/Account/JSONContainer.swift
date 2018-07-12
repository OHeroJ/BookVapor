//
//  JSONContainer.swift
//  App
//
//  Created by laijihua on 2018/6/20.
//

import Vapor


enum ResponseStatus: Int, Content {
    case ok = 0
    case error = 1
    case missesPara = 3
    case token = 4
    case unknown = 10

    case userExist = 20
    case userNotExist = 21
    case passwordError = 22

    var desc: String {
        switch self {
        case .ok:
            return "请求成功"
        case .error:
            return "请求失败"
        case .missesPara:
            return "缺少参数"
        case .token:
            return "Token 已经失效"
        case .unknown:
            return "未知错误"
        case .userExist:
            return "用户已经存在"
        case .userNotExist:
            return "用户不存在"
        case .passwordError:
            return "密码错误"

        }
    }
}

struct Empty: Content {}

struct JSONContainer<D: Content>: Content {
    private var status: ResponseStatus
    private var message: String
    private var data: D?

    init(status:ResponseStatus = .ok, message: String = ResponseStatus.ok.desc, data:D? = nil) {
        self.status = status
        self.message = message
        self.data = data
    }

    init(data: D) {
        self.status = .ok
        self.message = status.desc
        self.data = data
    }

    static func success(data: D) -> JSONContainer<D> {
        return JSONContainer(data:data)
    }

    static func error(message: String) -> JSONContainer<Empty> {
        return JSONContainer<Empty>(status: .error, message: message, data: nil)
    }

    static func error(status: ResponseStatus) -> JSONContainer<Empty> {
        return JSONContainer<Empty>(status: status, message: status.desc, data:nil)
    }
}

extension Future where T: Content{
    func makeJsonResponse(request: Request) throws -> Future<Response> {
        return try self.map { data in
            return JSONContainer(data: data)
        }.encode(for: request)
    }

    func makeErrorJsonResponse(status: ResponseStatus, message: String? = nil, request: Request) throws -> Future<Response> {
        return try self.map { data in
            return JSONContainer<Empty>(status: status, message: message ?? status.desc, data: nil)
        }.encode(for: request)
    }
}

extension Request {
    func makeJson<C>(response: JSONContainer<C>) throws -> Future<Response> {
        return try response.encode(for: self)
    }
}




