// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// CacheEntry.swift
// Copyright (c) 2022 Nemlig.com. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "PersistentDataCore",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PersistentDataCore",
            targets: ["PersistentDataCore"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/realm/realm-swift.git", from: "10.36.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "PersistentDataCore",
            dependencies: [.product(name: "RealmSwift", package: "realm-swift")]
        ),
        .testTarget(
            name: "PersistentDataCoreTests",
            dependencies: ["PersistentDataCore"]
        )
    ]
)
