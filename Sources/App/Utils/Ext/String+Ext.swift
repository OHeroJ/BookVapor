//
//  String+Ext.swift
//  App
//
//  Created by laijihua on 2018/9/5.
//

import Foundation

extension String {
    static func random(length: Int = 20) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""
        for _ in 0..<length {
            let count = base.count
            #if os(Linux)
            srandom(UInt32(time(nil)))
            let randomValue = UInt32(random() % count)
            #else
            let randomValue = arc4random_uniform(UInt32(count))
            #endif
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
}

