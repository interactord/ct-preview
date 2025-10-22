// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package: Package = .init(
  name: "DesignSystem",
  platforms: [
    .iOS(.v18),
    .macOS(.v26),
  ],
  products: [
    .library(
      name: "DesignSystem",
      targets: ["DesignSystem"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/airbnb/lottie-ios.git",
      from: "4.5.1"),
  ],
  targets: [
    .target(
      name: "DesignSystem",
      dependencies: [
        .product(name: "Lottie", package: "lottie-ios"),
      ],
      resources: [
        .process("Resources/Lottie/ani_typing_light.json"),
        .process("Resources/Lottie/ani_typing_dark.json"),
        .process("Resources/Lottie/loading.json"),
        .process("Resources/Lottie/splash_light.json"),
        .process("Resources/Lottie/splash_dark.json"),
      ]),
  ])
