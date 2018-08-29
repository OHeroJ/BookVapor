//
//  content.swift
//  App
//
//  Created by laijihua on 2018/8/29.
//

import Vapor

public func content(config: inout ContentConfig) throws {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    encoder.dateEncodingStrategy = .millisecondsSince1970
    decoder.dateDecodingStrategy = .millisecondsSince1970

    config.use(encoder: encoder, for: .json)
    config.use(decoder: decoder, for: .json)
}
