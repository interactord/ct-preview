import Speech
import NaturalLanguage

enum Confidence {
  case pass
  case fail
}

extension SpeechTranscriber.Result {
  // 해당 함수에서 현재 언어와 신뢰도를 판단한다. 해당값이 true일 경우, 화면에 전사가 나가는거고, false이면 화면에 전사가 나가지 않게 할것이다.
  // 해당 기능의 목표는 다른 언어(Locale)를 설정했을때, 잘못된 전사를 막기 위한 기능이다.
  // 예를들어 내가 한국어로 설정하고 일본어로 했을 경우, 신뢰도는 떨어져야한다. (우리 서비스의 기능은 한국어/일본어를 국한해서는 안된다.)
  func evaluationConfidence(locale: Locale) -> Confidence {
    guard isFinal else { return .pass }
    let textValue = String(text.characters).trimmingCharacters(in: .whitespacesAndNewlines)
    guard textValue.isEmpty == false else { return .fail }

    guard let expectedLanguage = locale.language.languageCode?.identifier.lowercased() else {
      return .pass
    }

    let recognizer = NLLanguageRecognizer()
    recognizer.processString(textValue)

    guard let detectedLanguage = recognizer.dominantLanguage?.rawValue.lowercased() else {
      return .fail
    }

    return detectedLanguage == expectedLanguage ? .pass : .fail
  }
}
