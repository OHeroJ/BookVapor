//
//  command.swift
//  App
//
//  Created by laijihua on 2018/8/29.
//
import Vapor

public func commands(config: inout CommandConfig) {
    config.useFluentCommands()
}
