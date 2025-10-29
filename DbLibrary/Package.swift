// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "DbLibrary",
  platforms: [
    .iOS(.v18)
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "DbLibrary",
      targets: ["DbLibrary"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/sqlite-data.git", from: "1.2.0"),
    .package(url: "https://github.com/pointfreeco/swift-structured-queries.git", from: "0.24.0", traits: ["StructuredQueriesCasePaths"]),
    .package(url: "https://github.com/pointfreeco/swift-case-paths.git", from: "1.7.2"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.23.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "DbLibrary",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "SQLiteData", package: "sqlite-data"),
      ]
    ),
    .testTarget(
      name: "DbLibraryTests",
      dependencies: ["DbLibrary"]
    ),
  ]
)
