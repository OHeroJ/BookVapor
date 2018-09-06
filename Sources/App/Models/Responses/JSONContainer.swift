//
//  JSONContainer.swift
//  App
//
//  Created by laijihua on 2018/6/20.
//

import Vapor

enum ResponseStatus: UInt, Content {
    case ok = 0  // 请求成功状态

    /// 接口失败
    case userExist = 20
    case userNotExist = 21
    case passwordError = 22
    case emailNotExist = 23
    case bookNotExist = 24
    case modelNotExist = 25
    case modelExisted = 26
    case authFail = 27
    case codeFail = 28
    case resonNotExist = 29

    var desc: String {
        switch self {
        case .ok:
            return "请求成功"
        case .userExist:
            return "用户已经存在"
        case .userNotExist:
            return "用户不存在"
        case .passwordError:
            return "密码错误"
        case .emailNotExist:
            return "邮箱不存在"
        case .bookNotExist:
            return "书籍不存在"
        case .modelNotExist:
            return "对象不存在"
        case .modelExisted:
            return "对象已存在"
        case .authFail:
            return "认证失败"
        case .codeFail:
            return "验证码错误"
        case .resonNotExist:
            return "不存在reason"
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

    init(data:D? = nil) {
        self.status = .ok
        self.message = self.status.desc
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
    func makeJson<T: Content>(_ content: T) throws -> Future<Response> {
        return try JSONContainer<T>(data: content).encode(for: self)
    }

    /// Void json
    func makeJson() throws -> Future<Response> {
        return try JSONContainer<Empty>(data: nil).encode(for: self)
    }
}
