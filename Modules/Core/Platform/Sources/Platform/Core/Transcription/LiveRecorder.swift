import Foundation
@preconcurrency import AVFoundation
import Functor
import Speech
import Domain

final actor LiveRecorder {
  private var transcriber: LiveTranscriber? = .none
  private let audioEngine: AVAudioEngine = .init()
}

extension LiveRecorder {

  func prepare(locale: Locale) async throws {
    if transcriber != nil { release() }

    try setupSession()
    self.transcriber = try await setupTranscriber(locale: locale)
    try await transcriber?.prepare()
  }

  func transcript() -> AsyncThrowingStream<TranscriptionEntity.Item, Error> {
    return .init { continuation in
      guard let transcriber else {
        continuation.finish(throwing: CompositeError.invalidTypeCasting)
        return
      }

      let recordTask = Task {
        do {
          for try await input in recodeStream() {
            try await transcriber.subscribe(buffer: input)
          }
          continuation.finish()
        } catch {
          continuation.finish(throwing: error)
        }
      }

      let streamTask = Task {
        do {
          for try await item in await transcriber.transcription() {
            continuation.yield(item)
          }
          continuation.finish()
        } catch {
          continuation.finish(throwing: error)
        }
      }

      continuation.onTermination = { _ in
        recordTask.cancel()
        streamTask.cancel()
      }
    }
  }

  func stop() async throws {
    audioEngine.stop()
    try await transcriber?.release()
  }

  func release() {
    transcriber = .none
  }
}

extension LiveRecorder {
  private func recodeStream() -> AsyncThrowingStream<AVAudioPCMBuffer, Error> {
    return .init { continuation in
      do {
        try setupAudioEngine()
        let format = audioEngine.inputNode.outputFormat(forBus: .zero)

        audioEngine.inputNode.installTap(
          onBus: .zero,
          bufferSize: 4096,
          format: format
        ) { buffer, _ in
          continuation.yield(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
      } catch {
        continuation.finish(throwing: error)
      }
    }
  }

  private func setupSession() throws {
    let session = AVAudioSession.sharedInstance()
    try session.setCategory(.playAndRecord, mode: .spokenAudio)
    try session.setActive(true, options: .notifyOthersOnDeactivation)
  }

  private func setupTranscriber(locale: Locale) async throws -> LiveTranscriber {
    await SpeechFunctor(locale: locale).releaseLocales()

    return .init(locale: locale)
  }

  private func setupAudioEngine() throws {
    audioEngine.inputNode.removeTap(onBus: .zero)
  }
}
