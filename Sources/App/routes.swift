import Routing
import Vapor


public func routes(_ router: Router) throws {

    router.get("welcome") { req in
        return "welcome"
    }

    let authRouteController = AuthenticationRouteController()
    try router.register(collection: authRouteController)

    let userRouteController = UserRouteController()
    try router.register(collection: userRouteController)

    let protectedRouteController = ProtectedRoutesController()
    try router.register(collection: protectedRouteController)

    let apiController = ApiRouteController()
    try router.register(collection: apiController)

    let chainController = ChainRouteController()
    try router.register(collection: chainController)
}
