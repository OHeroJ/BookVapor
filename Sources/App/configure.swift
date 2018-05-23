import FluentSQLite
import Vapor

/// Called before your application initializes.
///
/// https://docs.vapor.codes/3.0/getting-started/structure/#configureswift
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    try services.register(FluentSQLiteProvider())

    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)


    var middlewares = MiddlewareConfig()
    middlewares.use(ErrorMiddleware.self)
    services.register(middlewares)

    let sqlite: SQLiteDatabase
    if env.isRelease {
        sqlite = try SQLiteDatabase(storage: .file(path: Environment.get("SQLITE_PATH")!))
    } else {
        sqlite = try SQLiteDatabase(storage: .memory)
    }

    var databases = DatabasesConfig()
    databases.add(database: sqlite, as: .sqlite)
    services.register(databases)

    let migrations = MigrationConfig()

    services.register(migrations)

    try configureWebsockets(&services)
}

func configureWebsockets(_ services: inout Services) throws {
    let websockets = NIOWebSocketServer.default()
    try websocketRoutes(websockets)
    services.register(websockets, as: WebSocketServer.self)
}
