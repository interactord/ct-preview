import ProjectDescription
import ProjectDescriptionHelpers

let targetList: [Target] = [
  .target(
    name: "CT-Preview",
    destinations: .iOS,
    product: .app,
    productName: "CT-Preview",
    bundleId: "com.flitto.previewer",
    deploymentTargets: .none,
    infoPlist: .extendingDefault(with: .commonInfoValue()),
    sources: ["Sources/**"],
    resources: ["Resources/**"],
    copyFiles: .none,
    headers: .none,
    entitlements: .none,
    scripts: [],
    dependencies: compositeDependency,
    settings: .defaultConfigSettings(isDev: true),
    coreDataModels: [],
    environmentVariables: [:],
    launchArguments: [],
    additionalFiles: [],
    buildRules: [],
    mergedBinaryType: .automatic,
    mergeable: false,
    onDemandResourcesTags: .none),

    .target(
      name: "CT-MAC",
      destinations: .macOS,
      product: .app,
      productName: "CT-Preview",
      bundleId: "com.flitto.previewer",
      deploymentTargets: .none,
      infoPlist: .extendingDefault(with: .commonInfoValue()),
      sources: ["Sources/**"],
      resources: ["Resources/**"],
      copyFiles: .none,
      headers: .none,
      entitlements: .file(path: .relativeToRoot("Entitlements/CT-MAC.entitlements")),
      scripts: [],
      dependencies: compositeDependency,
      settings: .defaultConfigSettings(isDev: true),
      coreDataModels: [],
      environmentVariables: [:],
      launchArguments: [],
      additionalFiles: [],
      buildRules: [],
      mergedBinaryType: .automatic,
      mergeable: false,
      onDemandResourcesTags: .none),
]

let project = Project(
  name: "CT-Project",
  organizationName: "Flitto",
  options: .options(
    automaticSchemesOptions: .enabled(),
    defaultKnownRegions: .none,
    developmentRegion: .none,
    disableBundleAccessors: false,
    disableShowEnvironmentVarsInScriptPhases: false,
    disableSynthesizedResourceAccessors: false,
    textSettings: .textSettings(),
    xcodeProjectName: .none),
  packages: compositePackageList,
  settings: .none,
  targets: targetList,
  schemes: [],
  fileHeaderTemplate: .none,
  additionalFiles: [],
  resourceSynthesizers: .default)

private var compositeDependency: [TargetDependency] {
  [
    .package(product: "Architecture", type: .runtime, condition: .none),
    .package(product: "DesignSystem", type: .runtime, condition: .none),
    .package(product: "Domain", type: .runtime, condition: .none),
    .package(product: "Functor", type: .runtime, condition: .none),
    .package(product: "Platform", type: .runtime, condition: .none),
    .package(product: "LinkNavigatorSwiftUI", type: .runtime, condition: .none),
    .package(product: "Dashboard", type: .runtime, condition: .none),
  ]
}

private var compositePackageList: [Package] {
  [
    .local(path: .relativeToRoot("Modules/Core/Architecture")),
    .local(path: .relativeToRoot("Modules/Core/DesignSystem")),
    .local(path: .relativeToRoot("Modules/Core/Domain")),
    .local(path: .relativeToRoot("Modules/Core/Functor")),
    .local(path: .relativeToRoot("Modules/Core/Platform")),
     .local(path: .relativeToRoot("Modules/Core/LinkNavigatorSwiftUI")),
     .local(path: .relativeToRoot("Modules/Feature/Dashboard")),
  ]
}
