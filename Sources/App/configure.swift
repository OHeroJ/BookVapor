import FluentPostgreSQL
import Vapor
import Authentication
import APIErrorMiddleware

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


    let serverConfig = NIOServerConfig.default(hostname: "0.0.0.0",
                                               port: 8988)
    services.register(serverConfig)
    /// 配置全局的 middleware
    var middlewares = MiddlewareConfig()

    middlewares.use(APIErrorMiddleware.init(environment: env, specializations: [
        ModelNotFound()
    ]))

    let corsConfig = CORSMiddleware.Configuration(
        allowedOrigin: .originBased,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent],
        exposedHeaders: [
            HTTPHeaderName.authorization.description,
            HTTPHeaderName.contentLength.description,
            HTTPHeaderName.contentType.description,
            HTTPHeaderName.contentDisposition.description,
            HTTPHeaderName.cacheControl.description,
            HTTPHeaderName.expires.description
        ]
    )
    middlewares.use(CORSMiddleware(configuration: corsConfig))
    services.register(middlewares)

    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)

    let psqlConfig = PostgreSQLDatabaseConfig(hostname: "localhost",
                                              port: 5432,
                                              username: "root",
                                              database: "book",
                                              password: "lai12345")

    var databases = DatabasesConfig()
    databases.add(database: PostgreSQLDatabase(config: psqlConfig), as: .psql)
    services.register(databases)

    var migrations = MigrationConfig()
    migrations.add(model: Organization.self, database: .psql)
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: Menu.self, database: .psql)
    migrations.add(model: Role.self, database: .psql)
    migrations.add(model: OpLog.self, database: .psql)
    migrations.add(model: Right.self, database: .psql)
    migrations.add(model: Group.self, database: .psql)
    migrations.add(model: RoleRight.self, database: .psql)
    migrations.add(model: GroupRight.self, database: .psql)
    migrations.add(model: GroupRole.self, database: .psql)
    migrations.add(model: UserRight.self, database: .psql)
    migrations.add(model: UserRole.self, database: .psql)
    migrations.add(model: UserGroup.self, database: .psql)
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

    migrations.add(model: Notify.self, database: .psql)
    migrations.add(model: UserNotify.self, database: .psql)
    migrations.add(model: Subscription.self, database: .psql)
    services.register(migrations)
}

