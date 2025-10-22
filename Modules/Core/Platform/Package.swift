// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package: Package = .init(
  name: "Platform",
  platforms: [
    .iOS(.v26),
    .macOS(.v26),
  ],
  products: [
    .library(
      name: "Platform",
      targets: ["Platform"]),
  ],
  dependencies: [
    .package(path: "../../Core/Domain"),
    .package(path: "../../Core/Functor"),
    .package(
      url: "https://github.com/interactord/URLEncodedForm",
      .upToNextMajor(from: "1.0.9")),
    .package(
      url: "https://github.com/apple/swift-log.git",
      .upToNextMajor(from: "1.6.3")),
    .package(
      url: "https://github.com/google/generative-ai-swift",
      .upToNextMajor(from: "0.5.6")),
  ],
  targets: [
    .target(
      name: "Platform",
      dependencies: [
        "Domain",
        "Functor",
        "URLEncodedForm",
        .product(name: "Logging", package: "swift-log"),
        .product(name: "GoogleGenerativeAI", package: "generative-ai-swift"),
      ]),
  ])
