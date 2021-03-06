// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CobaltKit",
    platforms: [
            .macOS(.v10_15),
            .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "DiathekesvrConfig",
            targets: ["DiathekesvrConfig"]),
        .library(
            name: "CubicsvrConfig",
            targets: ["CubicsvrConfig"]),
        .library(
            name: "LunasvrConfig",
            targets: ["LunasvrConfig"])
    ],
    dependencies: [
            .package(url: "git@github.com:LebJe/TOMLKit.git", .exact("0.3.2"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CubicsvrConfig",
            dependencies: [
                .product(name: "TOMLKit", package: "TOMLKit"),
            ]),
        .target(
            name: "DiathekesvrConfig",
            dependencies: [
                .product(name: "TOMLKit", package: "TOMLKit"),
            ]),
        .target(
            name: "LunasvrConfig",
            dependencies: [
                .product(name: "TOMLKit", package: "TOMLKit"),
            ]),
    ]
)
