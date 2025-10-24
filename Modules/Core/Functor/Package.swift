// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package: Package = .init(
  name: "Functor",
  platforms: [
    .iOS(.v26),
    .macOS(.v26),
  ],
  products: [
    .library(
      name: "Functor",
      targets: ["Functor"]
    )
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "Functor",
      dependencies: [
      ]
    )
  ]
)
