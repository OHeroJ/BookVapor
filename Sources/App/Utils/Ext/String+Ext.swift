//
//  String+Ext.swift
//  App
//
//  Created by laijihua on 2018/9/5.
//

import Foundation
import Random

extension String {
    static func random(length: Int = 20) throws -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""
        for _ in 0..<length {
            let count = base.count
            let randomValue = try OSRandom().generate(UInt32.self) % UInt32(count)
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
}

