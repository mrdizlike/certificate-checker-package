// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "certificate-checker-package",
    defaultLocalization: "en",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "certificate-checker-package",
            targets: ["certificate-checker-package"]),
    ],
    
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-certificates.git",
            from: "0.6.0"
        )
    ],
    
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "certificate-checker-package",
            dependencies: [.product(name: "X509", package: "swift-certificates")]),
        .testTarget(
            name: "certificate-checker-packageTests",
            dependencies: ["certificate-checker-package"]),
    ]
)
