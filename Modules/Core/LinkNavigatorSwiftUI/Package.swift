// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package: Package = .init(
  name: "LinkNavigatorSwiftUI",
  platforms: [
    .iOS(.v18),
    .macOS(.v26),
  ],
  products: [
    .library(
      name: "LinkNavigatorSwiftUI",
      targets: ["LinkNavigatorSwiftUI"]),
  ],
  dependencies: [
    .package(path: "../../Core/DesignSystem"),
    .package(
      url: "https://github.com/interactord/URLEncodedForm",
      .upToNextMajor(from: "1.0.9")),
  ],
  targets: [
    .target(
      name: "LinkNavigatorSwiftUI",
      dependencies: [
        "URLEncodedForm",
        "DesignSystem",
      ]),
  ])
