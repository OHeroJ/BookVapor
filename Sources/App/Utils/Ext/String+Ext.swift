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
            #if os(Linux)
            let randomValue = Int(random() % UInt32(base.count))
            #else
            let randomValue = arc4random_uniform(UInt32(base.count))
            #endif
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
}

