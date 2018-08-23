//
//  EmailSender.swift
//  App
//
//  Created by laijihua on 2018/8/19.
//

import Vapor
import SwiftSMTP

final class EmailSender {
    enum Content {
        case register(emailTo: String, code: String)
        case accountActive(emailTo: String, url: String)
        case changePwd(emailTo: String, code: String)

        var emailTo: Mail.User {
            switch self {
            case let .register(emailTo, _),
                 let .accountActive(emailTo,_),
                 let .changePwd(emailTo, _):

                return Mail.User(name: "EMgamean", email: emailTo)
            }
        }

        var subject: String {
            switch self {
            case .register:
                return "注册验证码"
            case .changePwd:
                return "修改密码验证码"
            case .accountActive:
                return "激活账号"
            }
        }

        var text: String {
            switch self {
            case let .register(_, code):
                return "注册验证码是：\(code)"
            case let .changePwd(_, code):
                return "修改密码的验证码是: \(code)"
            case let .accountActive(emailTo: _, url):
                return "点击此链接激活账号：\(url)"
            }
        }
    }

    static func sendEmail(_ req: Request, content: EmailSender.Content) throws -> Future<Void> {
        let promise = req.eventLoop.newPromise(Void.self)
        let emailUser = Mail.User(name: "再书", email: "13576051334@163.com")
        let emailTo = content.emailTo
        let mail = Mail(from: emailUser, to: [emailTo], subject: content.subject, text: content.text)

        let smtp = SMTP(hostname: "smtp.163.com", email: "13576051334@163.com", password: "laijihua12345", port: 465, tlsMode: .requireTLS, domainName:"book.twicebook.top")
        DispatchQueue.global().async {
            smtp.send(mail)
            promise.succeed()
        }
        return promise.futureResult
    }
}
