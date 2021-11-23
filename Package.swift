// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "StateMachineMiddleware",
    products: [
        .library(name: "StateMachineMiddleware", targets: ["StateMachineMiddleware"])
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftRex/SwiftRex.git", .upToNextMajor(from: "0.8.8"))
    ],
    targets: [
        .target(name: "StateMachineMiddleware", dependencies: [.product(name: "CombineRex", package: "SwiftRex")])
    ]
)
