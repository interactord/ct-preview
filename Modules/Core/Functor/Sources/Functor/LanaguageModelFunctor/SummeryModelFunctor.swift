import Foundation
import FoundationModels
import NaturalLanguage

// MARK: - ChunkAccumulator

/// 청크 누적기 (함수형 상태 관리)
private struct ChunkAccumulator {
  let chunks: [String]
  let currentChunk: String
  let currentTokens: Int
  let maxTokens: Int

  static func empty(maxTokens: Int) -> Self {
    ChunkAccumulator(chunks: [], currentChunk: "", currentTokens: 0, maxTokens: maxTokens)
  }

  /// 새 문장 추가 여부 판단
  func shouldSplit(sentenceTokens: Int) -> Bool {
    !currentChunk.isEmpty && (currentTokens + sentenceTokens > maxTokens)
  }

  /// 현재 청크 완료 및 새 청크 시작
  func commit(with sentence: String, tokens: Int) -> Self {
    ChunkAccumulator(
      chunks: chunks + [currentChunk],
      currentChunk: sentence,
      currentTokens: tokens,
      maxTokens: maxTokens
    )
  }

  /// 현재 청크에 문장 추가
  func append(_ sentence: String, tokens: Int) -> Self {
    ChunkAccumulator(
      chunks: chunks,
      currentChunk: currentChunk + sentence,
      currentTokens: currentTokens + tokens,
      maxTokens: maxTokens
    )
  }

  /// 최종 청크 배열 반환
  func finalize() -> [String] {
    currentChunk.isEmpty ? chunks : chunks + [currentChunk]
  }
}

// MARK: - 함수형 유틸리티

extension Array where Element: Sendable {
  /// 배열을 지정된 크기의 청크로 분할
  func chunked(by size: Int) -> [[Element]] {
    stride(from: 0, to: count, by: size).map {
      Array(self[$0..<Swift.min($0 + size, count)])
    }
  }

  /// 비동기 map 연산 (Sendable 제약)
  func asyncMap<T: Sendable>(_ transform: @escaping @Sendable (Element) async throws -> T) async throws -> [T] {
    try await withThrowingTaskGroup(of: (Int, T).self) { group in
      for (index, element) in self.enumerated() {
        group.addTask { (index, try await transform(element)) }
      }

      var results: [(Int, T)] = []
      for try await result in group {
        results.append(result)
      }

      return results.sorted { $0.0 < $1.0 }.map { $0.1 }
    }
  }
}

// MARK: - 메인 Actor

@available(iOS 26.0, *)
public actor SummeryModelFunctor: Sendable {

  // MARK: Lifecycle

  // MARK: - 초기화

  public init() { }

  // MARK: Private

  // MARK: - 상수 정의

  /// 청크당 최대 토큰 수 (3B 모델 안전 마진)
  private let maxTokensPerChunk = 2000

  /// 병합 시 묶을 요약본 개수
  private let mergeFactor = 3

  /// 목표 압축률 (0.6 = 60%)
  private let compressionRatio = 0.6

}

// MARK: - Response Schema

@available(iOS 26.0, *)
extension SummeryModelFunctor {
  @Generable
  public struct IntegratedResponse: Equatable, Codable, Sendable {
    @Guide(description: "Summery Content")
    public let context: String
  }
}

// MARK: - Public API

@available(iOS 26.0, *)
extension SummeryModelFunctor {
  /// 긴 컨퍼런스 텍스트를 계층적으로 요약 (함수형 스타일)
  ///
  /// - Parameters:
  ///   - content: 요약할 전체 텍스트 (모국어)
  ///   - locale: 입력 및 출력 언어 로케일
  /// - Returns: 모국어 최종 요약본
  public func fetch(content: String, locale: Locale) async throws -> String {
    // Phase 1: 청크 분할
    let chunks = splitIntoChunks(content)

    // Phase 2 & 3: 계층적 요약 트리 구축
    let englishSummary = try await buildSummaryTree(chunks, locale: locale)

    // Phase 4: 최종 번역
    return try await translateToLocale(englishSummary, from: Locale(identifier: "en"), to: locale)
  }
}

// MARK: - 핵심 로직 (함수형)

@available(iOS 26.0, *)
extension SummeryModelFunctor {
  /// 텍스트를 청크로 분할 (함수형)
  private func splitIntoChunks(_ content: String) -> [String] {
    extractSentences(from: content)
      .reduce(into: ChunkAccumulator.empty(maxTokens: maxTokensPerChunk)) { acc, sentence in
        let tokens = estimateTokenCount(sentence)
        if acc.shouldSplit(sentenceTokens: tokens) {
          acc = acc.commit(with: sentence, tokens: tokens)
        } else {
          acc = acc.append(sentence, tokens: tokens)
        }
      }
      .finalize()
  }

  /// 계층적 요약 트리 구축 (함수형)
  private func buildSummaryTree(_ chunks: [String], locale: Locale) async throws -> String {
    let leafSummaries = try await chunks.asyncMap { chunk in
      try await self.summarizeChunk(chunk, from: locale, to: Locale(identifier: "en"))
    }

    return try await mergeRecursively(leafSummaries)
  }

  /// 재귀적 병합 (함수형)
  private func mergeRecursively(_ summaries: [String]) async throws -> String {
    guard summaries.count > 1 else { return summaries[0] }

    let merged = try await summaries
      .chunked(by: mergeFactor)
      .asyncMap { batch in
        try await self.mergeSummaries(batch)
      }

    return try await mergeRecursively(merged)
  }
}

// MARK: - 순수 함수 (Prompt Builders)

@available(iOS 26.0, *)
extension SummeryModelFunctor {
  /// 요약 프롬프트 생성 (순수 함수)
  private func buildSummaryPrompt(text: String, targetTokens: Int, locale: Locale) -> String {
    """
    Summarize the following text in \(locale.identifier) language using a hierarchical bullet point structure. \

    IMPORTANT:
    1. First identify the MAIN THEME/TOPIC of this section
    2. Then list key sub-topics under the main theme
    3. Add specific details under each sub-topic if needed

    Format (use "- " for each level with proper indentation):
    - [MAIN THEME]
      - Sub-topic 1
        - Detail 1-1
        - Detail 1-2
      - Sub-topic 2
        - Detail 2-1

    Target length: approximately \(targetTokens) tokens.

    Text:
    \(text)
    """
  }

  /// 병합 프롬프트 생성 (순수 함수)
  private func buildMergePrompt(summaries: [String], targetTokens: Int, locale: Locale) -> String {
    let combinedText = summaries.joined(separator: "\n\n")
    return """
      Merge the following summaries into a single coherent summary in \(locale.identifier) language. \

      CRITICAL REQUIREMENTS:
      1. Identify OVERARCHING BIG THEMES that span across multiple summaries
      2. Group related sub-topics under each big theme
      3. Eliminate redundancy while preserving key information
      4. Maintain clear 3-level hierarchy: Big Theme → Sub-topic → Details

      Hierarchical structure (use "- " with proper indentation):
      - [BIG THEME 1] (overarching topic covering multiple summaries)
        - Sub-topic 1-1 (merged from similar topics)
          - Important detail
          - Key point
        - Sub-topic 1-2
          - Specific information
      - [BIG THEME 2]
        - Sub-topic 2-1
          - Detail

      Target length: approximately \(targetTokens) tokens.

      Summaries to merge:
      \(combinedText)
      """
  }

  /// 번역 프롬프트 생성 (순수 함수)
  private func buildTranslationPrompt(summary: String, from: Locale, to: Locale) -> String {
    """
    Translate the following hierarchical bullet-point summary from \(from.identifier) to \(to.identifier). \

    REQUIREMENTS:
    1. Maintain EXACT 3-level hierarchy: Big Theme → Sub-topic → Details
    2. Preserve bullet point format with proper indentation
    3. Keep the same level of detail and structure
    4. Translate content naturally while preserving meaning

    Summary:
    \(summary)
    """
  }
}

// MARK: - 헬퍼 함수

@available(iOS 26.0, *)
extension SummeryModelFunctor {
  /// 텍스트에서 문장 추출 (NaturalLanguage 래핑)
  private func extractSentences(from text: String) -> [String] {
    let tokenizer = NLTokenizer(unit: .sentence)
    tokenizer.string = text

    var sentences: [String] = []
    tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
      sentences.append(String(text[range]))
      return true
    }

    return sentences
  }

  /// 토큰 수 추정 (순수 함수)
  private func estimateTokenCount(_ text: String) -> Int {
    Int(Double(text.count) * 1.5)
  }

  /// 단일 청크 요약 (프롬프트 빌더 활용)
  private func summarizeChunk(_ chunk: String, from _: Locale, to: Locale) async throws -> String {
    let targetTokens = Int(Double(estimateTokenCount(chunk)) * compressionRatio)
    let prompt = buildSummaryPrompt(text: chunk, targetTokens: targetTokens, locale: to)

    let session = LanguageModelSession()
    let response = try await session.respond(to: prompt, generating: IntegratedResponse.self)
    return response.content.context
  }

  /// 여러 요약본 병합 (프롬프트 빌더 활용)
  private func mergeSummaries(_ summaries: [String]) async throws -> String {
    let combinedText = summaries.joined(separator: "\n\n")
    let targetTokens = Int(Double(estimateTokenCount(combinedText)) * compressionRatio)
    let prompt = buildMergePrompt(summaries: summaries, targetTokens: targetTokens, locale: Locale(identifier: "en"))

    let session = LanguageModelSession()
    let response = try await session.respond(to: prompt, generating: IntegratedResponse.self)
    return response.content.context
  }

  /// 영어 요약본을 모국어로 번역 (프롬프트 빌더 활용)
  private func translateToLocale(_ summary: String, from: Locale, to: Locale) async throws -> String {
    let prompt = buildTranslationPrompt(summary: summary, from: from, to: to)

    let session = LanguageModelSession()
    let response = try await session.respond(to: prompt, generating: IntegratedResponse.self)
    return response.content.context
  }
}
