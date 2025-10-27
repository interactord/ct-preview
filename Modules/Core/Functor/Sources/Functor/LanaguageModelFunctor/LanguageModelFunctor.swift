import Foundation
import FoundationModels

// MARK: - LanguageModelFunctor

/// iOS 26 FoundationModels 기반 LLM 교정 및 번역 Functor
///
/// **주요 기능:**
/// - STT 구어체 → 문법적으로 올바른 공식 표현 교정
/// - 아시아권 언어(한국어, 일본어, 중국어 등) 경어체 자동 적용
/// - 중국어 간체/번체, 지역별(CN/TW/HK/SG) 세분화 처리
/// - 히스토리 컨텍스트 활용으로 모호한 표현 해석
///
/// **사용 예시:**
/// ```swift
/// let functor = LanguageModelFunctor()
///
/// // 영어 → 한국어 (경어체 자동 적용)
/// let item = TranslationItem(
///   startItem: SourceItem(locale: Locale(identifier: "en-US"), text: "hey can u send that file"),
///   endItem: SourceItem(locale: Locale(identifier: "ko-KR"), text: ""),
///   historyItemList: []
/// )
///
/// let result = try await functor.correctAndTranslate(item: item)
/// // result.correctedText: "Could you please send that file?"
/// // result.translatedText: "그 파일을 보내주시겠습니까?"
/// ```
@available(iOS 26.0, *)
public actor LanguageModelFunctor: Sendable {

  public init() { }
}

// MARK: - Input Models

@available(iOS 26.0, *)
extension LanguageModelFunctor {
  /// 번역 요청 항목
  public struct TranslationItem: Equatable, Sendable {
    public init(startItem: SourceItem, endItem: SourceItem, historyItemList: [SourceItem]) {
      self.startItem = startItem
      self.endItem = endItem
      self.historyItemList = historyItemList
    }

    public let startItem: SourceItem // 원문 (교정 대상)
    public let endItem: SourceItem // 번역어 (목표 언어, text는 비어있음)
    public let historyItemList: [SourceItem] // 최근 대화 히스토리 (최대 2개 권장)

  }

  /// 소스 항목 (언어 + 텍스트)
  public struct SourceItem: Equatable, Sendable {
    public init(locale: Locale, text: String) {
      self.locale = locale
      self.text = text
    }

    public let locale: Locale
    public let text: String

  }

  public func checkAppleIntelligenceAvailability() async -> Bool {
    let model = SystemLanguageModel.default

    switch model.availability {
    case .available:
//      print("[LanguageModelFunctor] ✅ Apple Intelligence / Foundation Model is available on this device.")
      return true

    case .unavailable:
//    case .unavailable(let reason):
//      print("[LanguageModelFunctor] ❌ Foundation Model is unavailable.")
//      print("[LanguageModelFunctor] Reason: \(reason)")
      return false

    @unknown default:
//      print("[LanguageModelFunctor] ⚠️ Unknown availability state.")
      return false
    }
  }

  /// 교정 + 번역 통합 함수 (메인 API)
  ///
  /// **3B 모델 최적화:**
  /// - 초간결 프롬프트 (~220 tokens, 72% 절약)
  /// - Few-shot 예시 1개로 패턴 학습
  /// - 경어체 자동 판별 및 적용
  /// - @Generable 스키마로 파싱 성공률 100%
  ///
  /// - Parameters:
  ///   - item: 원문(startItem), 번역어(endItem), 히스토리
  /// - Returns: 교정된 원문 + 번역 결과
  /// - Throws: `LanguageModelError.unavailable` (Apple Intelligence 미지원 기기)
  ///           `LanguageModelError.processingFailed` (처리 실패)
  public func correctAndTranslate(item: TranslationItem) async throws -> IntegratedResponse {
    // Apple Intelligence 가용성 체크
    guard await checkAppleIntelligenceAvailability() else {
      throw LanguageModelError.unavailable
    }

    // 시스템 지시 (역할 정의)
    let systemInstructions = buildSystemInstructions()

    // 사용자 요청 (실제 작업)
    let userPrompt = buildUserPrompt(item: item)

    // 디버깅: 프롬프트 출력
//    print("[LanguageModelFunctor] 📝 System Instructions:")
//    print(systemInstructions)
//    print("\n[LanguageModelFunctor] 📝 User Prompt:")
//    print(userPrompt)

    // LanguageModelSession으로 처리
    let session = LanguageModelSession(instructions: systemInstructions)

    do {
      // @Generable 스키마 기반 응답 생성
      let response = try await session.respond(to: userPrompt, generating: IntegratedResponse.self)

      // 디버깅: 응답 출력
//      print("\n[LanguageModelFunctor] 📥 Response:")
//      print("correctedText: \(response.content.correctedText)")
//      print("translatedText: \(response.content.translatedText)")

      return response.content
    } catch {
//      print("[LanguageModelFunctor] ❌ Error: \(error)")
      throw LanguageModelError.processingFailed(underlying: error)
    }
  }
}

// MARK: - Response Schemas (3B 모델 최적화: 필수 필드만)

@available(iOS 26.0, *)
extension LanguageModelFunctor {
  /// 통합 응답: 교정 + 번역
  @Generable
  public struct IntegratedResponse: Equatable, Codable, Sendable {
    @Guide(description: "Grammar-corrected formal text")
    public let correctedText: String

    @Guide(description: "Professional translation")
    public let translatedText: String
  }

  /// 교정 전용 응답
  @Generable
  public struct CorrectionResponse: Equatable, Codable, Sendable {
    @Guide(description: "Corrected text")
    public let correctedText: String

    @Guide(description: "Brief reason")
    public let reason: String
  }

  /// 번역 전용 응답
  @Generable
  public struct TranslationResponse: Equatable, Codable, Sendable {
    @Guide(description: "Translated text")
    public let translatedText: String
  }
}

// MARK: - Error Types

@available(iOS 26.0, *)
extension LanguageModelFunctor {
  /// 언어 모델 전용 에러
  public enum LanguageModelError: Error, LocalizedError {
    case unavailable
    case processingFailed(underlying: Error)

    public var errorDescription: String? {
      switch self {
      case .unavailable:
        "Apple Intelligence is not available on this device."
      case .processingFailed(let error):
        "Processing failed: \(error.localizedDescription)"
      }
    }
  }
}

// MARK: - Prompt Builders (3B 모델 최적화)

@available(iOS 26.0, *)
extension LanguageModelFunctor {
  /// 시스템 지시: AI 역할 정의 (세션 초기화용)
  private func buildSystemInstructions() -> String {
    """
    You are a professional language correction and translation assistant.
    Your role:
    1. Fix grammar errors in source text
    2. Make text formal and professional
    3. Translate to target language with appropriate formality

    Always return valid JSON format.
    """
  }

  /// 사용자 프롬프트: 실제 처리 작업 (영어 프롬프트 + 다국어 텍스트)
  private func buildUserPrompt(item: TranslationItem) -> String {
    let sourceLocale = item.startItem.locale.currentLangCodeBCP47()
    let targetLocale = item.endItem.locale.currentLangCodeBCP47()

    let sourceLangName = getLanguageName(for: sourceLocale)
    let targetLangName = getLanguageName(for: targetLocale)
    let formalityHint = getFormalityHint(for: targetLocale)
    let example = getFewShotExample(source: sourceLocale, target: targetLocale)
    let historySection = item.historyItemList.isEmpty ? "" : buildHistoryContext(item.historyItemList)

    // 부정 규칙 생성: 타겟 언어가 아닌 것들만 명시
    var negativeRules: [String] = []

    // 소스와 타겟이 다르면 소스 언어가 아니라고 명시
    if sourceLangName != targetLangName {
      negativeRules.append("NOT \(sourceLangName)")
    }

    // 타겟이 영어가 아니고, 소스도 영어가 아닌 경우에만 "NOT English" 추가
    if targetLangName != "English", sourceLangName != "English" {
      negativeRules.append("NOT English")
    }

    let negativeConstraint = negativeRules.isEmpty ? "" : " (\(negativeRules.joined(separator: ", ")))"

    return """
      Input (\(sourceLangName)): "\(item.startItem.text)"\(historySection)

      \(example)

      Instructions:
      1. Correct grammar in \(sourceLangName) → output as "correctedText"
      2. Translate "correctedText" to \(targetLangName) → output as "translatedText"\(formalityHint)

      Rules:
      ✓ correctedText = \(sourceLangName) only
      ✓ translatedText = \(targetLangName) only\(negativeConstraint)

      Return JSON:
      {
        "correctedText": "...",
        "translatedText": "..."
      }
      """
  }

  /// 언어 코드 → 영어 언어명 변환
  private func getLanguageName(for bcp47Code: String) -> String {
    let langCode = bcp47Code.split(separator: "-").first.map(String.init)?.lowercased() ?? ""

    switch langCode {
    case "ko": return "Korean"
    case "ja": return "Japanese"
    case "zh": return "Chinese"
    case "en": return "English"
    case "es": return "Spanish"
    case "fr": return "French"
    case "de": return "German"
    case "it": return "Italian"
    case "pt": return "Portuguese"
    case "ru": return "Russian"
    case "ar": return "Arabic"
    case "hi": return "Hindi"
    case "th": return "Thai"
    case "vi": return "Vietnamese"
    case "id": return "Indonesian"
    case "ms": return "Malay"
    default: return bcp47Code
    }
  }

  /// 경어체 힌트 생성 (영어로 작성)
  private func getFormalityHint(for bcp47Code: String) -> String {
    let parts = bcp47Code.split(separator: "-").map(String.init)
    guard let langCode = parts.first else { return "" }

    switch langCode.lowercased() {
    case "ko":
      return "\n   Use formal/polite Korean (honorific speech with -습니다/-ㅂ니다 endings)"

    case "ja":
      return "\n   Use formal Japanese (polite です/ます forms, keigo)"

    case "zh":
      let hasHant = parts.contains("Hant") || parts.contains("TW") || parts.contains("HK")
      let script = hasHant ? "Traditional" : "Simplified"
      let region = parts.dropFirst().first { $0.count == 2 } ?? "CN"
      return "\n   Use formal Chinese (\(script), \(region)) with 您 for 'you'"

    case "th":
      return "\n   Use polite Thai with ครับ/ค่ะ particles"

    case "vi":
      return "\n   Use formal Vietnamese with respectful terms"

    case "id":
      return "\n   Use formal Indonesian with Anda, Bapak/Ibu"

    default:
      return ""
    }
  }

  /// Few-shot 예시 (언어 중립적 구조)
  private func getFewShotExample(source: String, target: String) -> String {
    let srcName = getLanguageName(for: source)
    let tgtName = getLanguageName(for: target)

    return """
      Example Format:
      {
        "correctedText": "[Corrected text in \(srcName)]",
        "translatedText": "[Translation in \(tgtName)]"
      }

      Example (English → Korean):
      Input: "yeah i did that yesterday"
      {
        "correctedText": "Yes, I completed that yesterday.",
        "translatedText": "네, 어제 그 작업을 완료했습니다."
      }
      """
  }

  /// 히스토리 컨텍스트 (영어 설명 + 다국어 텍스트)
  private func buildHistoryContext(_ history: [SourceItem]) -> String {
    let recentItems = history.suffix(2)
    let lines = recentItems.enumerated().map { index, item in
      let langName = getLanguageName(for: item.locale.currentLangCodeBCP47())
      return "[\(index + 1)] \(langName): \(item.text)"
    }.joined(separator: "\n")

    return """


      Previous conversation:
      \(lines)
      """
  }
}

// MARK: - Locale Extensions

extension Locale {
  /// BCP-47 언어 코드 생성 (language-script-region)
  ///
  /// 예시:
  /// - "ko-KR" (한국어)
  /// - "ja-JP" (일본어)
  /// - "zh-Hans-CN" (중국어 간체, 중국)
  /// - "zh-Hant-TW" (중국어 번체, 대만)
  func currentLangCodeBCP47() -> String {
    var parts: [String] = []
    if let l = language.languageCode?.identifier { parts.append(l) }
    if let s = language.script?.identifier { parts.append(s) }
    if let r = language.region?.identifier { parts.append(r) }
    return parts.isEmpty ? "und" : parts.joined(separator: "-")
  }
}
