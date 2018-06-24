import FluentMySQL
import Vapor
import Authentication
import SendGrid

/// Called before your application initializes.
///
/// https://docs.vapor.codes/3.0/getting-started/structure/#configureswift
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    try services.register(AuthenticationProvider())

    let emailConfig = SendGridConfig(apiKey: "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")
    services.register(emailConfig)
    try services.register(SendGridProvider())

    let serverConfig = NIOServerConfig.default(hostname: "0.0.0.0",
                                               port: 8080)
    services.register(serverConfig)

    /// 配置全局的 middleware
    let middlewares = MiddlewareConfig()
    services.register(middlewares)

    try services.register(FluentMySQLProvider())
    let mysqlConfig = MySQLDatabaseConfig(hostname: "localhost",
                                          port: 3306,
                                          username: "root",
                                          password: "lai12345",
                                          database: "learn")

    var databases = DatabasesConfig()
    databases.add(database: MySQLDatabase(config: mysqlConfig),
                  as: .mysql)
    services.register(mysqlConfig)

    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .mysql)
    migrations.add(model: AccessToken.self, database: .mysql)
    migrations.add(model: RefreshToken.self, database: .mysql)
    migrations.add(model: ChatContent.self, database: .mysql)
    migrations.add(model: Friend.self, database: .mysql)
    migrations.add(model: PriceUnit.self, database: .mysql)
    migrations.add(model: BookClassify.self, database: .mysql)
    migrations.add(model: Book.self, database: .mysql)
    migrations.add(model: ActiveCode.self, database: .mysql)
    services.register(migrations)
    try configureWebsockets(&services)
}

func configureWebsockets(_ services: inout Services) throws {
    let websockets = NIOWebSocketServer.default()
    try websocketRoutes(websockets)
    services.register(websockets, as: WebSocketServer.self)
}
