//
//  WebsocketRoutes.swift
//  App
//
//  Created by laijihua on 2018/4/23.
//

import Foundation
import Vapor

struct PeerMessage: Codable {
    enum PeerType: String, Codable {
        case getBlock
        case createTransaction
        case createBlock
    }
    let method: PeerType
    let param: [String: Data]
}

func websocketRoutes(_ servicer: EngineWebSocketServer) throws {
    var pingSessions: [WebSocket] = []

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
}






