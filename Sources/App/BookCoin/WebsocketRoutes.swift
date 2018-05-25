//
//  WebsocketRoutes.swift
//  App
//
//  Created by laijihua on 2018/4/23.
//

import Foundation
import Vapor
import SwiftyJSON

struct PeerMessage: Codable {
    enum PeerType: String, Codable {
        case getBlock
        case createTransaction
        case createBlock
    }
    let method: PeerType
    let param: [String: Data]
}



func websocketRoutes(_ servicer: NIOWebSocketServer) throws {
    var pingSessions: [WebSocket] = [] // 连接者
    var rooms: [Int: Room] = [:]

    servicer.get("ping") { (ws, req) in
        pingSessions.append(ws)
        ws.onText({ (ws, msg) in
            if msg == "ping" {
                WebSocket.broadcast(msg: "pong", to: pingSessions)
            }
        })
        ws.onClose.always {
            pingSessions.removeIf{$0.isClosed}
        }
    }

    servicer.get("chain") { (ws, req) in
        ws.onBinary({ (ws, data) in
            guard let request = try? JSONDecoder().decode(PeerMessage.self, from: data) else {return}
            switch request.method {
            case .getBlock:
                break
            case .createTransaction: // 交易创建
               break
            case .createBlock:
                break
            }
        })
    }

    servicer.get("chat") { (ws, req) in
        var currentRoomId = 0
        var currentUserId = ""

        ws.onText({ (ws, message) in
            let json = (try? JSON(data: message.data(using: .utf8) ?? Data())) ?? .null
            print(rooms)
            let enterCode = Room.EnterCode(code: json["code"].int)
            switch enterCode {
            case .enter:
                guard let roomNum = json["data"]["roomNum"].int else {return}
                guard let userId = json["data"]["userId"].string else {return}
                var room: Room? = rooms[roomNum]
                if nil == room {
                    room = Room()
                    rooms[roomNum] = room
                    currentRoomId = roomNum
                    currentUserId = userId
                }
                room?.addUser(userId: userId, ws: ws)
            case .leave:
                guard let roomNum = json["data"]["roomNum"].int else {return}
                guard let userId = json["data"]["userId"].string else {return}
                guard let room: Room = rooms[roomNum] else {return}
                room.removeUser(userId: userId)
                if room.count == 0 {
                    rooms[roomNum] = nil
                }
            case .message:
                guard let roomNum = json["data"]["roomNum"].int else {return}
                guard let userId = json["data"]["userId"].string else {return}
//                guard let message = json["data"]["message"].string else {return}
                guard let room: Room = rooms[roomNum] else {return}
                let messge = json.rawString() ?? ""
                room.sendMsgToOthers(excludeUserId: userId, msg: messge)
            case .other: break
            }
        })

        ws.onClose.always {
            if let room = rooms[currentRoomId],
                room.userInRoom(userId: currentUserId) {
                room.removeUser(userId: currentUserId)
                if room.count == 0 {
                    rooms[currentRoomId] = nil
                    print("离开: \(currentUserId)")
                }
            }
        }
    }
}






