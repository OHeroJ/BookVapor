// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Hello",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.8"),
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor-community/pagination.git", from: "1.0.6"),
        .package(url: "https://github.com/vapor-community/sendgrid-provider.git", from: "3.0.5"),
        .package(url: "https://github.com/skelpo/APIErrorMiddleware.git", from: "0.3.5")
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "Authentication", "SendGrid", "Pagination", "FluentPostgreSQL", "APIErrorMiddleware"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

