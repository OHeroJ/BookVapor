//
//  RouteCollection+Email.swift
//  App
//
//  Created by laijihua on 2018/8/21.
//

import Vapor
import Crypto

extension RouteCollection {
    func sendMail(user: User, request: Request) throws -> Future<Void> {
        let codeStr = try MD5.hash(Data(Date().description.utf8)).hexEncodedString().lowercased()
        let code = ActiveCode(userId: user.id!, code: codeStr)

        return code.save(on: request)
            .flatMap{ code  in
                let scheme =  request.http.headers.firstValue(name: .host) ?? ""
                let linkUrl = "https://\(scheme)/api/users/activate/\(code.code)"
                let emailContent = EmailSender.Content.accountActive(emailTo: user.email, url: linkUrl)
                return try self.sendMail(request: request, content: emailContent)
        }
    }

    func sendMail(request: Request, content: EmailSender.Content) throws -> Future<Void> {
        return try EmailSender.sendEmail(request, content: content)
    }
}
