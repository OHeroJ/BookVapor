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
    case emailNotExist = 23

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
        case .emailNotExist:
            return "邮箱不存在"
        }
    }
}

struct Empty: Content {}

struct JSONContainer<D: Content>: Content {
    private var status: ResponseStatus
    private var message: String
    private var data: D?

    static var successEmpty: JSONContainer<Empty> {
        return JSONContainer<Empty>()
    }

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

extension Future where T: Content {
    func makeJson(on request: Request) throws -> Future<Response> {
        return try self.map { data in
            return JSONContainer(data: data)
        }.encode(for: request)
    }
}

extension Future where T == Void {
    func makeJson(request: Request) throws -> Future<Response> {
        return try self.transform(to: JSONContainer<Empty>.successEmpty).encode(for: request)
    }
}

extension Future where T == Either<Content, Content> {
    func makeJson(on request: Request) throws -> Future<Response>  {
        return try self.makeJson(on: request)
    }
}

extension Request {
    /// data json
    func makeJson<C>(response: JSONContainer<C>) throws -> Future<Response> {
        return try response.encode(for: self)
    }

    /// error json
    func makeJson(error message: String) throws -> Future<Response> {
        return try JSONContainer<Empty>.error(message: message).encode(for: self)
    }

    /// Void json
    func makeJson() throws -> Future<Response> {
        return try JSONContainer<Empty>(data: nil).encode(for: self)
    }
}



extension Either where T: Content, U: Content {
    func makeJson(on request: Request) throws -> Future<Response> {
        switch self {
        case let .left(x):
            return try JSONContainer<Left>(data: x).encode(for: request)
        case let .right(x):
            return try JSONContainer<Right>(data: x).encode(for: request)
        }
    }
}




