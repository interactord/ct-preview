import Foundation
import FoundationModels

@available(iOS 26.0, *)
public struct LanguageModelFunctor: Sendable {

  let systemPrompt: String?
  let session: LanguageModelSession

  public init(systemPrompt: String? = .none) {
    self.systemPrompt = systemPrompt
    self.session = LanguageModelSession(instructions: systemPrompt ?? defaultPrompt)
  }
}

@available(iOS 26.0, *)
extension LanguageModelFunctor {
  public func checkAppleIntelligenceAvailability() async -> Bool {
    let model = SystemLanguageModel.default

    switch model.availability {
    case .available:
      print("[LanguageModelFunctor] ✅ Apple Intelligence / Foundation Model is available on this device.")
      return true
    case .unavailable(let reason):
      print("[LanguageModelFunctor] ❌ Foundation Model is unavailable.")
      print("[LanguageModelFunctor] Reason: \(reason)")
      return false
    @unknown default:
      print("[LanguageModelFunctor] ⚠️ Unknown availability state.")
      return false
    }
  }

  public func correct(originalText: String, translationLocale: Locale) async -> LanguageFunctor.CorrectItem? {
    do {
      return try await session.respond(
        to: generateInput(originalText: originalText, translationLocale: translationLocale),
        generating: LanguageFunctor.CorrectItem.self)
      .content
    } catch {
      print("[LanguageModelFunctor][ERROR] \(error)")
      return .none
    }
  }

  func generateInput(originalText: String, translationLocale: Locale) -> String {
     """
     Task: Refine the source sentence and produce a formal translation.
     
     TargetLanguageCode: \(translationLocale.language.languageCode?.identifier  ?? "en")
     
     OutputRequirements:
     - text: keep original language; grammatically and stylistically refined.
     - translationText: must be written strictly in TargetLanguageCode without mixing other languages.
     - Preserve meaning and respectful, professional tone.
     
     OriginalText:
     \(originalText)
     
     OriginalLanguageHint: auto
     """
  }
}

@available(iOS 26.0, *)
extension LanguageFunctor {
  @Generable
  public struct CorrectItem: Equatable, Codable, Sendable {
    @Guide(description: "Inference reliability or confidence level")
    public let condition: String

    @Guide(description: "Grammatically and stylistically refined sentence in the original language")
    public let text: String

    @Guide(description:
            "Formal translation strictly in the target language specified by `TargetLanguageCode`; do not mix languages")
    public let translationText: String

    @Guide(description: "ISO 639-1 language code for `translationText` (e.g., en, ko); MUST equal TargetLanguageCode")
    public let translatedLanguageCode: String
  }
}

private let defaultPrompt = """
You are a multilingual linguistic assistant that refines and translates real-time speech-to-text (STT) results.

Your task is to polish and translate sentences so that they can be gracefully and respectfully presented to a general audience. 
All languages should sound elegant, polite, and suitable for public communication.

Follow these principles strictly:
1. Correct grammar, punctuation, wording, and spacing errors in the STT input.
2. Translate mixed-language content into the appropriate target language based on the provided context.
3. Replace any slang, casual speech, or informal wording with formal and polite expressions.
4. Maintain fluency and natural flow consistent with the previous translation history.
5. Ensure tone and meaning remain faithful to the original speaker, but always sound dignified and respectful.
6. Provide only the refined or translated text — no explanations, JSON, or metadata.
7. The final output should be suitable for written communication that reflects elegance and professionalism.

This prompt ensures the output reads as refined writing intended for shared public viewing, free of slang or overly casual tone.
"""
