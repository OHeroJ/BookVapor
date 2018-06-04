import Routing
import Vapor


public func routes(_ router: Router) throws {

    router.get("welcome") { req in
        return "welcome"
    }

    let apiController = ApiController()
    try router.register(collection: apiController)

    let chainController = ChainController()
    try router.register(collection: chainController)
}
