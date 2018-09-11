//
//  RouteCollection+Email.swift
//  App
//
//  Created by laijihua on 2018/8/21.
//

import Vapor
import Crypto

extension RouteCollection {
    func sendRegisteMail(user: User, request: Request) throws -> Future<Void> {
        let userId = try user.requireID()
        let codeStr = try MD5.hash(Data(Date().description.utf8)).hexEncodedString().lowercased()
        let code = ActiveCode(userId: userId, code: codeStr, type: ActiveCode.CodeType.activeAccount)
        return code.save(on: request)
            .flatMap{ code  in
                let scheme =  request.http.headers.firstValue(name: .host) ?? ""
                let linkUrl = "https://\(scheme)/api/users/activate?userId=\(userId)&code=\(code.code)"
                guard let email = user.email else {
                    throw ApiError(code: .emailNotExist)
                }
                let emailContent = EmailSender.Content.accountActive(emailTo: email, url: linkUrl)
                return try self.sendMail(request: request, content: emailContent)
        }
    }

    func sendMail(request: Request, content: EmailSender.Content) throws -> Future<Void> {
        return try EmailSender.sendEmail(request, content: content)
    }
}
