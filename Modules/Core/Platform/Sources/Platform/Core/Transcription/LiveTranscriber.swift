import Domain
import Functor
import Speech
import SwiftUI
import NaturalLanguage
import CoreMedia

// MARK: - LiveTranscriberV2

fileprivate actor SpeechModelV2 {
  struct LanguageStateUpdate {
    let locale: Locale
    let lock: LanguageLockUpdate
    let confidenceSnapshot: [String: Int]
  }

  enum LanguageLockUpdate {
    case lock(String)
    case unlock
  }

  private struct DraftStat {
    var count: Int
    var locale: Locale
  }

  let locale: Locale
  let module: SpeechTranscriber
  private var draftStatistics: [String: DraftStat] = [:]

  init(locale: Locale) {
    self.locale = locale
    self.module = .init(locale: locale, preset: .liveDefaultPresetV2)
  }

  func updateLanguageState(isFinal: Bool, detectedLocale: Locale) -> LanguageStateUpdate {
    let key = Self.languageKey(for: detectedLocale)
    var stat = draftStatistics[key] ?? .init(count: 0, locale: detectedLocale)
    stat.count += 1
    stat.locale = detectedLocale
    draftStatistics[key] = stat

    let dominant = draftStatistics.values.max { lhs, rhs in
      if lhs.count == rhs.count {
        return lhs.locale.identifier < rhs.locale.identifier
      }
      return lhs.count < rhs.count
    } ?? stat

    let snapshot = draftStatistics.reduce(into: [String: Int]()) { partialResult, entry in
      partialResult[entry.value.locale.identifier.lowercased()] = entry.value.count
    }

    if isFinal {
      draftStatistics.removeAll()
      return .init(locale: dominant.locale, lock: .unlock, confidenceSnapshot: snapshot)
    } else {
      return .init(locale: dominant.locale, lock: .lock(Self.identifier(for: self.locale)), confidenceSnapshot: snapshot)
    }
  }

  static func identifier(for locale: Locale) -> String {
    locale.identifier.lowercased()
  }

  private static func languageKey(for locale: Locale) -> String {
    locale.language.languageCode?.identifier.lowercased() ?? locale.identifier.lowercased()
  }
}

@available(iOS 26.0, *)
final actor LiveTranscriberV2: Sendable {

  // MARK: Lifecycle

  init(localeA: Locale, localeB: Locale?) {
    modelA = .init(locale: localeA)
    if let localeB { modelB = .init(locale: localeB) }
    else { modelB = .none }

    analyzer = .init(modules: [modelA.module, modelB?.module].compactMap { $0 })
    var identifiers: Set<String> = [SpeechModelV2.identifier(for: localeA)]
    if let localeB { identifiers.insert(SpeechModelV2.identifier(for: localeB)) }
    availableLocaleIdentifiers = identifiers
    enabledLocaleIdentifiers = identifiers
    currentLockedLocaleIdentifier = .none
  }

  // MARK: Internal

  private let modelA: SpeechModelV2
  private let modelB: SpeechModelV2?
  private let analyzer: SpeechAnalyzer
  var analyzerFormat: AVAudioFormat?
  private var inputSequence: AsyncStream<AnalyzerInput>?
  private var inputBuilder: AsyncStream<AnalyzerInput>.Continuation?
  private let converter = BufferConverter()
  private var enabledLocaleIdentifiers: Set<String>
  private var availableLocaleIdentifiers: Set<String>
  private var currentLockedLocaleIdentifier: String?

  func prepare() async throws {
    try await ensureModel()

    let moduleA = modelA.module
    let moduleB = modelB?.module
    analyzerFormat = await SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith: [moduleA, moduleB].compactMap { $0 })
    (inputSequence, inputBuilder) = AsyncStream<AnalyzerInput>.makeStream()

    guard let inputSequence else { return }
    try await analyzer.start(inputSequence: inputSequence)
  }

  func enable(locale: Locale) {
    let identifier = SpeechModelV2.identifier(for: locale)
    availableLocaleIdentifiers.insert(identifier)

    if let locked = currentLockedLocaleIdentifier {
      if locked == identifier {
        enabledLocaleIdentifiers = [identifier]
      }
    } else {
      enabledLocaleIdentifiers.insert(identifier)
    }
  }

  func disable(locale: Locale) {
    let identifier = SpeechModelV2.identifier(for: locale)
    availableLocaleIdentifiers.remove(identifier)
    enabledLocaleIdentifiers.remove(identifier)

    if currentLockedLocaleIdentifier == identifier {
      currentLockedLocaleIdentifier = nil
      enabledLocaleIdentifiers = availableLocaleIdentifiers
    }
  }

  func setEnabledLocales(_ locales: [Locale]) {
    let identifiers = Set(locales.map { SpeechModelV2.identifier(for: $0) })
    availableLocaleIdentifiers = identifiers

    if let locked = currentLockedLocaleIdentifier, identifiers.contains(locked) {
      enabledLocaleIdentifiers = [locked]
    } else {
      currentLockedLocaleIdentifier = nil
      enabledLocaleIdentifiers = identifiers
    }
  }

  @MainActor
  func transcription() -> AsyncThrowingStream<TranscriptionEntity.Item, Error> {
    .init { continuation in
      let emitIfConfident: @Sendable (SpeechTranscriber.Result, SpeechModelV2, Locale?) async -> Void = { result, sourceModel, otherLocale in

        if let otherLocale {
          let detectedLocale = LocaleDetectorV2.detectLocale(for: result.text, primary: sourceModel.locale, secondary: otherLocale)
          let stateUpdate = await sourceModel.updateLanguageState(isFinal: result.isFinal, detectedLocale: detectedLocale)
          await self.applyLanguageLock(update: stateUpdate.lock)
          let confidenceSnapshot = stateUpdate.confidenceSnapshot.isEmpty ? nil : stateUpdate.confidenceSnapshot

          if result.isFinal {
            guard !result.text.toString().trimming().isEmpty else { return }
            guard result.evaluationConfidence(locale: sourceModel.locale) == .pass else { return }
            let nonDetectedLocale = sourceModel.locale == otherLocale ? sourceModel.locale : otherLocale

            continuation.yield(.init(
              id: UUID().uuidString,
              localeA: sourceModel.locale,
              localeB: nonDetectedLocale,
              text: result.text,
              isFinal: result.isFinal,
              createAt: Date().timeIntervalSince1970,
              localeConfidence: confidenceSnapshot
            ))
          } else {
            continuation.yield(.init(
              id: UUID().uuidString,
              localeA: detectedLocale,
              localeB: .none,
              text: result.text,
              isFinal: result.isFinal,
              createAt: Date().timeIntervalSince1970,
              localeConfidence: confidenceSnapshot
            ))
          }
        } else {
          if result.isFinal {
            guard !result.text.toString().trimming().isEmpty else { return }
            continuation.yield(.init(
              id: UUID().uuidString,
              localeA: sourceModel.locale,
              localeB: .none,
              text: result.text,
              isFinal: result.isFinal,
              createAt: Date().timeIntervalSince1970,
              localeConfidence: .none
            ))
          } else {
            continuation.yield(.init(
              id: UUID().uuidString,
              localeA: sourceModel.locale,
              localeB: .none,
              text: result.text,
              isFinal: result.isFinal,
              createAt: Date().timeIntervalSince1970,
              localeConfidence: .none
            ))
          }
        }


      }

      let taskA = Task {
        do {
          let moduleA = modelA.module
          let localeA = modelA.locale
          let secondaryLocaleB = modelB?.locale
          for try await result in moduleA.results {
            guard await self.isLocaleEnabled(localeA) else { continue }
            await emitIfConfident(result, modelA, secondaryLocaleB)
          }
        } catch {
          continuation.finish(throwing: error)
        }
      }

      let taskB = Task {
        if let modelB {
          do {
            let moduleB = modelB.module
            let localeB = modelB.locale
            let primaryLocaleA = modelA.locale
            for try await result in moduleB.results {
              guard await self.isLocaleEnabled(localeB) else { continue }
              await emitIfConfident(result, modelB, primaryLocaleA)
            }
          } catch {
            continuation.finish(throwing: error)
          }
        }
      }

      continuation.onTermination = { _ in
        taskA.cancel()
        taskB.cancel()
      }
    }
  }

  func subscribe(buffer: AVAudioPCMBuffer) async throws {
    guard let inputBuilder, let analyzerFormat else {
      throw NSError(domain: "TranscriptionError.invalidAudioDataType", code: -1)
    }

    let converted = try converter.convertBuffer(buffer, to: analyzerFormat)
    let input = AnalyzerInput(buffer: converted)
    inputBuilder.yield(input)
  }

  func release() async throws {
    inputBuilder?.finish()
    analyzerFormat = .none
    try await analyzer.finalizeAndFinishThroughEndOfInput()
  }

  // MARK: Private

  private func ensureModel() async throws { }

  private func applyLanguageLock(update: SpeechModelV2.LanguageLockUpdate) {
    switch update {
    case .unlock:
      guard currentLockedLocaleIdentifier != nil else { return }
      currentLockedLocaleIdentifier = nil
      enabledLocaleIdentifiers = availableLocaleIdentifiers
    case .lock(let identifier):
      guard availableLocaleIdentifiers.contains(identifier) else { return }
      guard currentLockedLocaleIdentifier != identifier else { return }
      currentLockedLocaleIdentifier = identifier
      enabledLocaleIdentifiers = [identifier]
    }
  }

  private func isLocaleEnabled(_ locale: Locale) -> Bool {
    let identifier = SpeechModelV2.identifier(for: locale)
    return enabledLocaleIdentifiers.contains(identifier)
  }

}

// MARK: - LocaleDetectorV2

fileprivate enum LocaleDetectorV2 {
  static func detectLocale(for text: AttributedString, primary: Locale, secondary: Locale?) -> Locale {
    guard let secondary else { return primary }

    let rawText = text.toString().trimmingCharacters(in: .whitespacesAndNewlines)
    let locales = [(primary, languageCode(for: primary)), (secondary, languageCode(for: secondary))]

    guard rawText.isEmpty == false else { return locales.first!.0 }

    let recognizer = NLLanguageRecognizer()
    recognizer.processString(rawText)
    let hypotheses = recognizer.languageHypotheses(withMaximum: 2)
    let dominant = recognizer.dominantLanguage?.rawValue.lowercased()

    let best = locales.max { lhs, rhs in
      score(code: lhs.1, dominant: dominant, hypotheses: hypotheses)
        < score(code: rhs.1, dominant: dominant, hypotheses: hypotheses)
    }

    return best?.0 ?? primary
  }

  private static func score(
    code: String,
    dominant: String?,
    hypotheses: [NLLanguage: Double]
  ) -> Double {
    let dominantBonus: Double = (dominant == code) ? 1 : 0
    let hypothesisScore = hypotheses[NLLanguage(rawValue: code)] ?? 0
    return dominantBonus + hypothesisScore
  }

  private static func languageCode(for locale: Locale) -> String {
    locale.language.languageCode?.identifier.lowercased() ?? "en"
  }
}

@available(iOS 26.0, *)
extension SpeechTranscriber.Preset {
  fileprivate static var liveDefaultPresetV2: SpeechTranscriber.Preset {
    .init(
      transcriptionOptions: [
        .etiquetteReplacements
      ],
      reportingOptions: [
        .fastResults,
        .volatileResults,
      ],
      attributeOptions: [
        .audioTimeRange,
        .transcriptionConfidence
      ]
    )
  }
}


extension AttributedString {
  fileprivate func toString() -> String {
    String(characters[...])
  }
}

extension String {
  fileprivate func trimming() -> String {
    trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
