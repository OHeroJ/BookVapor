// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Hello",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.4"),
        .package(url: "https://github.com/vapor/fluent-mysql.git", from: "3.0.0-rc.3"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0-rc"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/crypto.git", from: "3.2.0"),
        .package(url: "https://github.com/vapor/console.git", from: "3.0.2")
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentMySQL", "Vapor", "SwiftyJSON", "Authentication", "Crypto", "Logging"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

