//
//  EmailSender.swift
//  App
//
//  Created by laijihua on 2018/8/19.
//

import Vapor
import SwiftSMTP

final class EmailSender {
    static func sendEmail(_ req: Request) throws -> Future<Bool> {
        let promise = req.eventLoop.newPromise(Bool.self)

        let emailUser = Mail.User(name: "再书", email: "13576051334@163.com")
        let emailTo = Mail.User(name: "EMgamean", email: "1164258202@qq.com")
        let mail = Mail(from: emailUser, to: [emailTo], subject: "再书邮件", text: "Any other use would be")

        let smtp = SMTP(hostname: "smtp.163.com", email: "13576051334@163.com", password: "laijihua12345", port: 465, tlsMode: .requireTLS, domainName:"book.twicebook.top")
        smtp.send(mail) { (error) in
            if let error = error {
                promise.fail(error: error)
            } else {
                promise.succeed(result: true)
            }
        }
        return promise.futureResult
    }
}
