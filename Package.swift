// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "debounced-closure",
    platforms: [.iOS(.v14), .macOS(.v11), .tvOS(.v14), .watchOS(.v7)],
    products: [
        .library(name: "DebouncedClosure", targets: ["DebouncedClosure"]),
    ],
    targets: [        
        .target(name: "DebouncedClosure"),
        .testTarget(name: "UnitTests", dependencies: ["DebouncedClosure"]),
        .testTarget(name: "IntegrationTests", dependencies: ["DebouncedClosure"]),
    ]
)
