import Routing
import Vapor


public func routes(_ router: Router) throws {

    router.get("welcome") { req in
        return "welcome"
    }

    router.get("senderEmail") { request in
        return try EmailSender.sendEmail(request, content: .accountActive(emailTo: "1164258202@qq.com", url: "https://baidu.com")).transform(to: HTTPStatus.ok)
    }

    router.get("scheme") { request in
        return request
            .http
            .headers
            .firstValue(name: HTTPHeaderName.host) ?? ""
    }

    do {
    let aa = try "c2RmanNvb2pvc2Rmam9qbw==".base64decode()
    print(aa)
    } catch {
        print("error")
    }

    func handleTestPost(_ request: Request) throws -> Future<User> {
        return try request.content.decode(User.self)
    }

    router.post("test", use: handleTestPost)

    let authRouteController = AuthenticationRouteController()
    try router.register(collection: authRouteController)

    let userRouteController = UserRouteController()
    try router.register(collection: userRouteController)

    let sysRouteController = SysRouteController()
    try router.register(collection: sysRouteController)

    let protectedRouteController = ProtectedRoutesController()
    try router.register(collection: protectedRouteController)

    let accountRouteController = AccountRouteController()
    try router.register(collection: accountRouteController)

    let bookRouteController = BookRouteController()
    try router.register(collection: bookRouteController)

    let wishBookRouteController = WishBookRouteController()
    try router.register(collection: wishBookRouteController)

    let searchRouteController = SearchRouteController()
    try router.register(collection: searchRouteController)

    let newsRouteController = NewsRouteController()
    try router.register(collection: newsRouteController)
}
