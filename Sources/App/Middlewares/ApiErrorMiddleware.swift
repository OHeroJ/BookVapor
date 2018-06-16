//
//  ApiErrorMiddleware.swift
//  App
//
//  Created by laijihua on 2018/6/4.
//

import Vapor

struct ErrorResult {
    let message: String
    let status: HTTPStatus?
    let identifier: String?
    init(message: String, status: HTTPStatus?, identifer: String? = "-1") {
        self.message = message
        self.status = status
        self.identifier = identifer
    }
}

protocol ErrorCatchingSpecialization {
    func convert(error: Error, on request: Request?) -> ErrorResult?
}


struct ModelNotFound: ErrorCatchingSpecialization {
    init() {}
    func convert(error: Error, on request: Request?) -> ErrorResult? {
        if let error = error as? Debuggable, error.identifier == "modelNotFound" {
            return ErrorResult(message: error.reason, status: .notFound)
        }
        return nil
    }
}

final class ApiErrorMiddleware: Middleware, ServiceType {

    var specializations: [ErrorCatchingSpecialization]

    let environment: Environment

    init(environment: Environment, specializations: [ErrorCatchingSpecialization] = []) {
        self.specializations = specializations
        self.environment = environment
    }

    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        return Future.flatMap(on: request, {
            return try next.respond(to: request)
        }).mapIfError({ (error) -> Response in
            return self.response(for: error, with: request)
        })
    }

    private func response(for error: Error, with request: Request) -> Response {
        var result: ErrorResult!

        for convert in self.specializations {
            if let formatted = convert.convert(error: error, on: request) {
                result = formatted
                break
            }
        }
        if result == nil {
            switch error {
            case let abort as AbortError:
                result = ErrorResult(message: abort.reason, status: abort.status, identifer: abort.identifier)
            case let debuggable as Debuggable where !self.environment.isRelease:
                let reason = debuggable.debuggableHelp(format: .short)
                result = ErrorResult(message: reason, status: .internalServerError, identifer: debuggable.identifier)
            default:
                #if !os(macOS)
                if let error = error as? CustomStringConvertible {
                    result = ErrorResult(message: error.description, status: nil)
                } else {
                    result = ErrorResult(message: "Unknow error.", status: nil)
                }
                #else
                result = ErrorResult(message: (error as CustomStringConvertible).description, status: nil)
                #endif
            }
        }

        let json: Data
        do {
            json = try JSONEncoder().encode(["message": result.message, "code": result.identifier])
        } catch {
            json = Data("{\"message\": \"Unable to encode error to JSON\", \"code\": \"-1\"}".utf8)
        }

        let httpResponse = HTTPResponse(
            status: result.status ?? .badRequest,
            headers: ["Content-Type": "application/json"],
            body: HTTPBody(data: json)
        )
        return Response(http: httpResponse, using: request.sharedContainer)
    }

    static func makeService(for worker: Container) throws -> ApiErrorMiddleware {
        return ApiErrorMiddleware(environment: worker.environment, specializations: [ModelNotFound()])
    }
}
