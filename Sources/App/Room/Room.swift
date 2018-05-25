//
//  Room.swift
//  App
//
//  Created by laijihua on 2018/5/23.
//

import Foundation
import Vapor
import SwiftyJSON

final class Room {
    enum EnterCode: Int {
        case enter = 2001
        case leave = 2002
        case message = 2003
        case other = 0

        var string: String {return "\(self)"}
        var code: Int {return self.rawValue}

        init(code: Int?) {
            switch code {
            case 2001: self = .enter
            case 2002: self = .leave
            case 2003: self = .message
            default: self = .other
            }
        }
    }

    struct Replay {
        var code: EnterCode
        var data: [String: Any]
        var string: String {
            let result: [String: Any] = [
                "code": code.code,
                "data": data
            ]
            return JSON(result).rawString() ?? ""
        }
    }

    private var connections: [String: WebSocket] = [:]

    var count: Int {return connections.count}

    func userInRoom(userId: String) -> Bool {
        return connections.keys.filter({$0 == userId}).count > 0
    }

    func addUser(userId: String, ws: WebSocket) {
        let connection = connections[userId]
        if nil == connection {
            connections[userId] = ws
        }
        let replay = Replay(code: .enter, data: ["userId": userId])
        sendMsgToOthers(excludeUserId: userId, msg: replay.string)
    }

    func removeUser(userId: String) {
        connections[userId] = nil
        let replay = Replay(code: .leave, data: ["userId": userId])
        sendMsgToOthers(excludeUserId: userId, msg: replay.string)
    }

    func sendMsgToOthers(excludeUserId: String, msg: String) {
        for (key, ws) in connections {
            if key == excludeUserId {
                continue
            } else {
                ws.send(msg)
            }
        }
    }

    func sendMsg(targetUserId: String, msg: String) {
        if let ws = connections[targetUserId] {
            ws.send(msg)
        }
    }
}

extension Room: CustomDebugStringConvertible {
    var debugDescription: String {
        return "room: \(connections), count: \(count)"
    }
}
