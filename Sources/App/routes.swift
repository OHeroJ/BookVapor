import Routing
import Vapor

struct TestModel: Content {
    let test: String
}

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example

    router.get("hello") { req in
        return "<html>Hello, world!</html>"
    }

    router.get("console") { req in
        return "console"
    }

    let chainController = ChainController()
    router.get("blocks", use: chainController.blocks)

}
