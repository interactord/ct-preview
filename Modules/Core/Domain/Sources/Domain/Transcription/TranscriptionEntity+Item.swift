import Foundation

extension TranscriptionEntity {

  public struct Item: Equatable, Sendable, Identifiable {
    public let uuid: String?
    public let startLocale: Locale
    public let endLocale: Locale?
    public var text: AttributedString
    public let isFinal: Bool
    public var translation: TranslationItem?

    public init(
      uuid: String? = .none,
      startLocale: Locale,
      endLocale: Locale?,
      text: AttributedString,
      isFinal: Bool,
      translation: TranslationItem? = .none)
    {
      self.uuid = uuid
      self.startLocale = startLocale
      self.endLocale = endLocale
      self.text = text
      self.isFinal = isFinal
      self.translation = translation
    }

    public var id: String {
      uuid ?? "\(startLocale) + \(text) + \(isFinal)"
    }
  }

  public struct TranslationItem: Equatable, Sendable, Identifiable {
    public let id: String
    public let locale: Locale
    public let text: String

    public init(id: String, locale: Locale, text: String) {
      self.id = id
      self.locale = locale
      self.text = text
    }
  }
}
