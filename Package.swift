// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Hello",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.4"),
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0-rc"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0-rc"),
        .package(url: "https://github.com/vapor-community/pagination.git", from: "1.0.6"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor-community/sendgrid-provider.git", from: "3.0.5")

    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "SwiftyJSON", "Authentication", "SendGrid", "Pagination", "FluentPostgreSQL"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

