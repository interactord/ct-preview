// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package: Package = .init(
  name: "Domain",
  platforms: [
    .iOS(.v26),
    .macOS(.v26),
  ],
  products: [
    .library(
      name: "Domain",
      targets: ["Domain"]
    )
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "Domain",
      dependencies: [
      ]
    )
  ]
)
