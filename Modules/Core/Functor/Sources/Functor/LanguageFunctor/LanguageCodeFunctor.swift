import Foundation

// MARK: - LanguageCodeFunctor

public enum LanguageCodeFunctor {

  // MARK: Public

  public static var deviceCode: String {
    UserDefaults.standard.object(forKey: Const.langCodeKey) as? String ?? getOSDefaultLangCode()
  }

  public static func savedDeviceCode(langCode: String?) {
    var mapLangCode: String { langCode ?? getOSDefaultLangCode() }
    UserDefaults.standard.set(mapLangCode, forKey: Const.langCodeKey)
  }

  public static func getOSDefaultLangCode() -> String {
    guard let preferredLanguage = Locale.preferredLanguages.first else {
      return defaultCode
    }

    return preferredLanguage.compare(text: "zh-Hans", convertText: "zh-CN")
      ?? preferredLanguage.compare(text: "zh-Hant", convertText: "zh-TW")
      ?? preferredLanguage.compare(text: "pt-BR", convertText: "pt-BR")
      ?? preferredLanguage.components(separatedBy: "-").first
      ?? defaultCode
  }

  // MARK: Private

  private enum Const {
    static let langCodeKey = "LangCode"
  }

  private static let defaultCode = "ko-KR"

}

extension String {
  fileprivate func compare(text: String, convertText: String) -> String? {
    guard lowercased().range(of: text.lowercased()) != nil else { return .none }
    return convertText
  }
}
