//
//  Data+Ext.swift
//  App
//
//  Created by laijihua on 2018/4/23.
//

import Foundation
import Crypto

extension Data {
    init<T>(from value: T) {
        var value = value
        self.init(buffer: UnsafeBufferPointer.init(start: &value, count: 1))
    }

    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes{ $0.pointee }
    }

    var sha256: Data {
        return (try? SHA256.hash(self)) ?? Data()
    }
}
