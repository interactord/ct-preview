import Foundation
import ProjectDescription

extension [String: Plist.Value] {

  // MARK: Public

  public static func commonInfoValue() -> [String: Plist.Value] {
    defaultInfoValue()
      .merging(customPropertyInfoValue()) { $1 }
  }

  // MARK: Internal

  static func defaultInfoValue() -> [String: Plist.Value] {
    [
      "CFBundleDevelopmentRegion": "$(DEVELOPMENT_LANGUAGE)",
      "CFBundleDisplayName": "${PRODUCT_NAME}",
      "CFBundleShortVersionString": .string(.appVersion()),
      "CFBundleVersion": .string(.appBuildVersion()),
      "LSHasLocalizedDisplayName": .boolean(true),
      "UIApplicationSupportsMultipleScenes": .boolean(false),
      "UISupportedInterfaceOrientations": .array([
        "UIInterfaceOrientationPortrait"
      ]),
      "UISupportedInterfaceOrientations~ipad": .array([
        "UIInterfaceOrientationPortrait",
        "UIInterfaceOrientationLandscapeLeft",
        "UIInterfaceOrientationLandscapeRight",
      ]),
      "UIStatusBarHidden": .boolean(true),
      "UIRequiresFullScreen": .boolean(true),
      "LSRequiresIPhoneOS": .boolean(true),
      "UIApplicationSceneManifest": .dictionary([
        "UIApplicationSupportsMultipleScenes": .boolean(false)
      ]),
      "LSMinimumSystemVersion": "14.0",
      "UIApplicationSupportsIndirectInputEvents": .boolean(true),
      "UILaunchScreen": .dictionary([:]),
      "UISceneConfigurations": .dictionary([
        "UIApplicationSupportsMultipleScenes": .boolean(false),
        "UISceneConfigurations": .dictionary([
          "UIWindowSceneSessionRoleApplication": .array([.dictionary([
            "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate",
            "UISceneConfigurationName": "Default Configuration",
          ])])
        ]),
      ]),
      "ITSAppUsesNonExemptEncryption": .boolean(false),
      "NSAppTransportSecurity": .dictionary([
        "NSAllowsArbitraryLoads": .boolean(true)
      ]),
      "FirebaseAppDelegateProxyEnabled": .boolean(false),
      "NSCameraUsageDescription": "Camera access is needed to capture QR Code.",
      "NSMicrophoneUsageDescription": "Microhpone access is needed to capture Voice",
    ]
  }

  static func customPropertyInfoValue() -> [String: Plist.Value] {
    [
      "Mode": .string("$(Mode)")
    ]
  }
}

extension Settings {

  // MARK: Public

  public static func defaultConfigSettings(isDev: Bool) -> Settings {
    .settings(
      base: defaultSettingDictionary(isDev: isDev),
      configurations: [],
      defaultSettings: .recommended
    )
  }

  // MARK: Private

  private static func defaultSettingDictionary(isDev: Bool) -> SettingsDictionary {
    [
      "CODE_SIGN_IDENTITY": "iPhone Developer",
      "CODE_SIGN_STYLE": "Automatic",
      "DEVELOPMENT_TEAM": "7836J6Z5N8",
      "ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS": "YES",
      "Mode": isDev ? "Development" : "Production",
      "SWIFT_VERSION": "6.0",
      "ENABLE_HARDENED_RUNTIME": "YES",
    ]
  }
}

extension String {
  public static func appVersion() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yy.MM.dd"
    formatter.locale = Locale(identifier: "ko_KR")
    return formatter.string(from: Date())
  }

  public static func appBuildVersion() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMddHHmmsss"
    formatter.locale = Locale(identifier: "ko_KR")
    return formatter.string(from: Date())
  }
}
