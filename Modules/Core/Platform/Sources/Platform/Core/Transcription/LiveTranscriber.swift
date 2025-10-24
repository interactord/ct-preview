import Domain
import Functor
import Speech
import SwiftUI

// MARK: - LiveTranscriber

@available(iOS 26.0, *)
final actor LiveTranscriber: Sendable {

  // MARK: Lifecycle

  init(locale: Locale) {
    let module = SpeechTranscriber(locale: locale, preset: .default)

    self.module = module
    self.locale = locale
    analyzer = .init(modules: [module])
  }

  // MARK: Internal

  let module: SpeechTranscriber
  let locale: Locale
  let analyzer: SpeechAnalyzer
  var analyzerFormat: AVAudioFormat?

  func prepare() async throws {
    try await ensureModel()

    analyzerFormat = await SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith: [module])
    (inputSequence, inputBuilder) = AsyncStream<AnalyzerInput>.makeStream()

    guard let inputSequence else { return }
    try await analyzer.start(inputSequence: inputSequence)
  }

  @MainActor
  func transcription() -> AsyncThrowingStream<TranscriptionEntity.Item, Error> {
    .init { continuation in
      let task = Task {
        do {
          for try await case let result in module.results {
            continuation.yield(.init(
              startLocale: locale,
              endLocale: .none,
              text: result.text,
              isFinal: result.isFinal
            ))
          }
        } catch {
          continuation.finish(throwing: error)
        }
      }

      // onTermination is Sendable; do not touch actor state directly here.
      continuation.onTermination = { _ in
        task.cancel()
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

  private var inputSequence: AsyncStream<AnalyzerInput>?
  private var inputBuilder: AsyncStream<AnalyzerInput>.Continuation?
  private let converter = BufferConverter()

}

@available(iOS 26.0, *)
extension LiveTranscriber {

  /// - Note:
  ///     앞에서 다운로드 점검은 할것이지만, 언어팩때문에 문제 생기면 이쪽 코드 보안해야함
  private func ensureModel() async throws { }
}

@available(iOS 26.0, *)
extension SpeechTranscriber.Preset {
  fileprivate static var `default`: SpeechTranscriber.Preset {
    .init(
      transcriptionOptions: [
        .etiquetteReplacements
      ],
      reportingOptions: [
        .fastResults,
        .volatileResults,
      ],
      attributeOptions: [
        .audioTimeRange
      ]
    )
  }
}
