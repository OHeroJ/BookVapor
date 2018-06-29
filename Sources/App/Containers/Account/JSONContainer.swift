//
//  JSONContainer.swift
//  App
//
//  Created by laijihua on 2018/6/20.
//

import Vapor

struct JSONContainer<D: Content>: Content {
    private var code: Int
    private var message: String
    private var data: D?

    init(code:Int = 0, message:String = "OK", data:D? = nil) {
        self.code = code
        self.message = message
        self.data = data
    }
}

extension Content {
    func convertToCustomContainer(code: Int = 0, messae: String = "ok") -> JSONContainer<Self> {
        return JSONContainer(code: code, message: messae, data: self)
    }

    func convertToErrorContainer(code: Int, message: String) -> JSONContainer<Self> {
        return self.convertToCustomContainer(code: code, messae: message)
    }

    func convertToSuccessContainer() -> JSONContainer<Self> {
        return self.convertToCustomContainer()
    }
}

extension Future where T: Content {

    func convertToCustomContainer(code: Int = 0, messae: String = "ok") -> Future<JSONContainer<T>> {
        return self.map(to: JSONContainer<T>.self, { result in
            return result.convertToCustomContainer()
        })
    }
}


