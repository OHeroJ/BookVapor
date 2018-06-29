import Routing
import Vapor


public func routes(_ router: Router) throws {

    router.get("welcome") { req in
        return "welcome"
    }

    router.get("scheme") { request in
        return request
            .http
            .headers
            .firstValue(name: HTTPHeaderName.host) ?? ""
    }

    let authRouteController = AuthenticationRouteController()
    try router.register(collection: authRouteController)

    let userRouteController = UserRouteController()
    try router.register(collection: userRouteController)

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

    let chainController = ChainRouteController()
    try router.register(collection: chainController)

}
