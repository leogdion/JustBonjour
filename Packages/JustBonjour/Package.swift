// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JustBonjour",
    platforms: [.macOS(.v14), .iOS(.v17), .tvOS(.v17)],
    products: [
        .executable(name: "App", targets: ["App"]),
        .library(name: "JBKit", targets: ["JBKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0-beta.4"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
        .package(url: "https://github.com/swift-server/swift-service-lifecycle.git", from: "2.6.0"),
        .package(url: "https://github.com/apple/swift-nio-transport-services.git", from: "1.20.0"),
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.6.0")
    ],
    targets: [
        .executableTarget(name: "App",
            dependencies: [
              "JBKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Hummingbird", package: "hummingbird"),
                .product(name: "ServiceLifecycle", package: "swift-service-lifecycle"),
                .product(name: "NIOTransportServices", package: "swift-nio-transport-services")
            ],
            path: "Sources/App",
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://github.com/swift-server/guides#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .target(name: "JBKit", dependencies: [.product(name: "SwiftProtobuf", package: "swift-protobuf")]),
        .testTarget(name: "AppTests",
            dependencies: [
                .byName(name: "App"),
                .product(name: "HummingbirdTesting", package: "hummingbird")
            ],
            path: "Tests/AppTests"
        )
    ]
)
