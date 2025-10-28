import Foundation
import FoundationModels
import NaturalLanguage

@available(iOS 26.0, *)
public actor SummeryModelFunctorV2: Sendable {
  private let maxTokensPerChunk = 2000
  private let mergeFactor = 3
  private let compressionRatio = 0.6
  private let minimumTargetTokens = 120
  private let maxSummaryTokensPerChunk = 600
  private let maxMergeSummaryTokens = 800
  private let maxMergeBatchTokens = 2400
  private let english = Locale(identifier: "en")
  private let referenceLocale = Locale(identifier: "en")

  public init() { }

  public func fetch(content: String, locale: Locale) async throws -> String {
    let chunks = split(content)
    let leafSummaries = try await chunks.asyncMap { chunk in
      try await self.summarize(chunk, inputLocale: locale)
    }
    let englishSummary = try await merge(leafSummaries)
    return try await translate(englishSummary, from: english, to: locale)
  }

  @Generable
  struct Response: Equatable, Codable, Sendable {
    @Guide(description: "Hierarchical summary")
    let context: String
  }

  private func split(_ text: String) -> [String] {
    let tokenizer = NLTokenizer(unit: .sentence)
    tokenizer.string = text

    var chunks: [String] = []
    var current = ""
    var currentTokens = 0

    tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
      let sentence = String(text[range])
      let sentenceTokens = tokenCount(of: sentence)

      if !current.isEmpty && currentTokens + sentenceTokens > maxTokensPerChunk {
        chunks.append(current)
        current = ""
        currentTokens = 0
      }

      current.append(sentence)
      currentTokens += sentenceTokens
      return true
    }

    if !current.isEmpty { chunks.append(current) }
    return chunks.isEmpty ? [text] : chunks
  }

  private func summarize(_ chunk: String, inputLocale: Locale) async throws -> String {
    let prompt = summaryPrompt(text: chunk, inputLocale: inputLocale)
    return try await request(prompt, enforceDepth: true)
  }

  private func merge(_ summaries: [String]) async throws -> String {
    guard summaries.count > 1 else { return summaries[0] }

    let batches = chunkSummaries(summaries)

    let merged = try await batches
      .asyncMap { batch in
        try await self.request(self.mergePrompt(summaries: batch), enforceDepth: true)
      }

    return try await merge(merged)
  }

  private func translate(_ summary: String, from: Locale, to: Locale) async throws -> String {
    if sharesLanguage(from, to) { return summary }
    return try await request(translationPrompt(summary: summary, from: from, to: to))
  }

  private func request(_ prompt: String, enforceDepth: Bool = false, attempt: Int = 0) async throws -> String {
    let session = LanguageModelSession()
    let response = try await session.respond(to: prompt, generating: Response.self)
    let text = response.content.context

    if enforceDepth && !text.contains("\n  - ") && attempt == 0 {
      let reminder = prompt + "\n\nREMINDER: Use at least two bullet levels by adding indented \"  - \" items."
      return try await request(reminder, enforceDepth: enforceDepth, attempt: 1)
    }

    return text
  }

  private func summaryPrompt(text: String, inputLocale: Locale) -> String {
    let targetTokens = targetTokenCount(for: text, cap: maxSummaryTokensPerChunk)
    return """
    Summarize the following \(languageName(for: inputLocale)) text in \(languageName(for: english)) with hierarchical bullet points.

    Requirements:
    - Start with a main theme bullet using "- ".
    - Provide at least two indented sub-points using "  - ".
    - Add deeper details with "    - " when helpful.
    - Ensure the summary is at least \(minimumTargetTokens) tokens and aims for \(targetTokens) tokens.

    Text:
    \(text)
    """
  }

  private func mergePrompt(summaries: [String]) -> String {
    let combined = summaries.joined(separator: "\n\n")
    let targetTokens = targetTokenCount(for: combined, cap: maxMergeSummaryTokens)
    return """
    Merge the following summaries into one \(languageName(for: english)) summary with a clear 3-level bullet hierarchy.

    Requirements:
    - Group related ideas under shared main bullets ("- ").
    - Provide at least two sub-points per main theme ("  - ").
    - Include details when necessary ("    - ").
    - Output length should be at least \(minimumTargetTokens) tokens and target \(targetTokens) tokens.

    Summaries:
    \(combined)
    """
  }

  private func translationPrompt(summary: String, from: Locale, to: Locale) -> String {
    """
    Translate the bullet-point summary from \(languageName(for: from)) to \(languageName(for: to)) while preserving indentation, bullet markers, and hierarchy. Do not add explanations or switch back to \(languageName(for: from)).

    Summary:
    \(summary)
    """
  }

  private func tokenCount(of text: String) -> Int {
    Int(Double(text.count) * 1.5)
  }

  private func targetTokenCount(for text: String, cap: Int? = nil) -> Int {
    let baseline = max(minimumTargetTokens, Int(Double(tokenCount(of: text)) * compressionRatio))
    guard let cap else { return baseline }
    return min(cap, baseline)
  }

  private func languageName(for locale: Locale) -> String {
    if let code = locale.languageCode?.lowercased(),
       let name = referenceLocale.localizedString(forLanguageCode: code) {
      return name.capitalized
    }

    if let identifierName = referenceLocale.localizedString(forIdentifier: locale.identifier) {
      return identifierName.capitalized
    }

    return locale.identifier
  }

  private func sharesLanguage(_ lhs: Locale, _ rhs: Locale) -> Bool {
    guard let left = lhs.languageCode?.lowercased(),
          let right = rhs.languageCode?.lowercased() else {
      return lhs.identifier == rhs.identifier
    }
    return left == right
  }

  private func chunkSummaries(_ summaries: [String]) -> [[String]] {
    var batches: [[String]] = []
    var current: [String] = []
    var currentTokens = 0

    for summary in summaries {
      let tokens = tokenCount(of: summary)
      if !current.isEmpty && (current.count >= mergeFactor || currentTokens + tokens > maxMergeBatchTokens) {
        batches.append(current)
        current = []
        currentTokens = 0
      }
      current.append(summary)
      currentTokens += tokens
    }

    if !current.isEmpty { batches.append(current) }
    return batches
  }
}
