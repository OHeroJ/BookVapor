import FluentPostgreSQL
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
    try services.register(FluentPostgreSQLProvider())
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

    let psqlConfig = PostgreSQLDatabaseConfig(hostname: "localhost",
                                              port: 5432,
                                              username: "root",
                                              database: "book",
                                              password: "lai12345")
    services.register(psqlConfig)

    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .psql)

    migrations.add(model: AccessToken.self, database: .psql)
    migrations.add(model: RefreshToken.self, database: .psql)
    
    migrations.add(model: Friend.self, database: .psql)
    migrations.add(model: PriceUnit.self, database: .psql)
    migrations.add(model: BookClassify.self, database: .psql)
    migrations.add(model: Book.self, database: .psql)
    migrations.add(model: ActiveCode.self, database: .psql)
    migrations.add(model: Feedback.self, database: .psql)
    migrations.add(model: MessageBoard.self, database: .psql)
    migrations.add(model: WishBook.self, database: .psql)
    migrations.add(model: WishBookComment.self, database: .psql)
    migrations.add(model: PriceUnit.self, database: .psql)
    migrations.add(model: ChatContent.self, database: .psql)
    services.register(migrations)
    try configureWebsockets(&services)
}

func configureWebsockets(_ services: inout Services) throws {
    let websockets = NIOWebSocketServer.default()
    try websocketRoutes(websockets)
    services.register(websockets, as: WebSocketServer.self)
}
