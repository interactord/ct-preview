// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package: Package = .init(
  name: "Dashboard",
  platforms: [
    .iOS(.v26),
    .macOS(.v26),
  ],
  products: [
    .library(
      name: "Dashboard",
      targets: ["Dashboard"]),
  ],
  dependencies: [
    .package(path: "../../Core/Architecture"),
    .package(path: "../../Core/DesignSystem"),
    .package(path: "../../Core/Functor"),
    .package(path: "../../Core/Domain"),
    .package(path: "../../Core/Platform"),
    .package(path: "../../Core/LinkNavigatorSwiftUI"),
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture.git",
      from: "1.20.0"),
  ],
  targets: [
    .target(
      name: "Dashboard",
      dependencies: [
        "Architecture",
        "DesignSystem",
        "Functor",
        "Domain",
        "Platform",
        "LinkNavigatorSwiftUI",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]),
  ])
