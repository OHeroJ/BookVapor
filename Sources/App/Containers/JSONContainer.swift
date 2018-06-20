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
}

extension Future where T: Content {

    func convertToCustomContainer(code: Int = 0, messae: String = "ok") -> Future<JSONContainer<T>> {
        return self.map(to: JSONContainer<T>.self, { result in
            return result.convertToCustomContainer()
        })
    }
}


