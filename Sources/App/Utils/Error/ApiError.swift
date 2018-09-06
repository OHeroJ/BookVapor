//
//  ApiError.swift
//  App
//
//  Created by laijihua on 2018/9/6.
//

import Foundation
import Vapor

/// 将错误200， 错误信息由接口体现
struct ApiError: Debuggable {
    var identifier: String
    var reason: String
    var code: Code

    init(code: Code, message: String? = nil) {
        self.identifier = "api error: \(code.rawValue)"
        self.reason = message ?? code.desc
        self.code = code
    }
}

struct ApiErrorContainer: Content {
    let status: UInt
    let message: String
}

extension ApiError {
    typealias Code = ResponseStatus
}

extension ApiError: AbortError {
    var status: HTTPResponseStatus {
        return .ok
    }
}
