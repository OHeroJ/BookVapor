import Routing
import Vapor


public func routes(_ router: Router) throws {

    router.get("welcome") { req in
        return "welcome"
    }

    router.get("hello") { req in
       return "hello"
    }

    router.post("hello") { req in
        return "hello"
    }

    router.get("console") { req in
        return "console"
    }

    let chainController = ChainController()
    router.get("blocks", use: chainController.blocks)

    router.group("chat") { (srouter) in
        srouter.post("login"){ req in
            return "login"
        }

        srouter.post("register"){ req  in
            return "register"
        }
    }


}
