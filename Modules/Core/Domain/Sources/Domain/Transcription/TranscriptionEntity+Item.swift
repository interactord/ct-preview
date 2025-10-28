import Foundation

extension TranscriptionEntity {

  public struct Item: Equatable, Sendable, Identifiable, Codable {

    // MARK: Lifecycle

    public init(
      id: String,
      localeA: Locale,
      localeB: Locale?,
      text: AttributedString,
      isFinal: Bool,
      translation: TranslationItem? = .none,
      createAt: TimeInterval,
      localeConfidence: [String: Int]? = .none
    ) {
      self.id = id
      self.localeA = localeA
      self.localeB = localeB
      self.text = text
      self.isFinal = isFinal
      self.translation = translation
      self.createAt = createAt
      self.localeConfidence = localeConfidence
    }

    // MARK: Public

    public let id: String
    public let localeA: Locale
    public let localeB: Locale?
    public var text: AttributedString
    public let isFinal: Bool
    public var translation: TranslationItem?
    public let createAt: TimeInterval
    public var localeConfidence: [String: Int]?
  }

  public struct TranslationItem: Equatable, Sendable, Identifiable, Codable {
    public init(id: String, locale: Locale, text: String) {
      self.id = id
      self.locale = locale
      self.text = text
    }

    public let id: String
    public let locale: Locale
    public let text: String

  }
}
