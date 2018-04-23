//
//  WebsocketRoutes.swift
//  App
//
//  Created by laijihua on 2018/4/23.
//

import Foundation
import Vapor

func websocketRoutes(_ servicer: EngineWebSocketServer) throws {

    servicer.get("echo") { (ws, req) in
        ws.onText({ (ws, msg) in
            ws.send(msg)
        })
    }

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
}



// Mark: Help

extension WebSocket {
    public static func broadcast(msg: String, to all: [WebSocket]) {
        all.forEach { $0.send(msg) }
    }
}


extension Future where Expectation == String {
    public func send(to websocket: WebSocket) -> Future<Expectation> {
        return self.flatMap(to: Expectation.self) { (data) in
            websocket.send(data)
            return self
        }
    }
}

extension Future where Expectation == Data {
    public func send(to websocket: WebSocket) -> Future<Expectation> {
        return self.flatMap(to: Expectation.self) { (data) in
            websocket.send(data)
            return self
        }
    }
}

extension Array {
    mutating func removeIf(closure: (Element) -> Bool ) {
        for (index, element) in self.enumerated() {
            if closure(element) {
                self.remove(at: index)
            }
        }
    }
}

