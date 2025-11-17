// swift-tools-version: 5.10
// Copyright (C) 2025, Shyamal Suhana Chandra
// The tools used to build, test, and package the Yankovinator software.

import PackageDescription

let package = Package(
    name: "Yankovinator",
    platforms: [
        .macOS(.v14),  // Build target (runtime requires macOS 15.0+ for Foundation Models)
        .iOS(.v17)     // Build target (runtime requires iOS 18.0+ for Foundation Models)
    ],
    products: [
        .library(
            name: "Yankovinator",
            targets: ["Yankovinator"]),
        .executable(
            name: "yankovinator",
            targets: ["YankovinatorCLI"]),
        .executable(
            name: "keyword-generator",
            targets: ["KeywordGeneratorCLI"]),
        .executable(
            name: "benchmark",
            targets: ["BenchmarkCLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
    ],
    targets: [
        .target(
            name: "Yankovinator",
            dependencies: []),
        .executableTarget(
            name: "YankovinatorCLI",
            dependencies: [
                "Yankovinator",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
        .executableTarget(
            name: "KeywordGeneratorCLI",
            dependencies: [
                "Yankovinator",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
        .executableTarget(
            name: "BenchmarkCLI",
            dependencies: [
                "Yankovinator",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
        .testTarget(
            name: "YankovinatorTests",
            dependencies: ["Yankovinator"]),
    ]
)

