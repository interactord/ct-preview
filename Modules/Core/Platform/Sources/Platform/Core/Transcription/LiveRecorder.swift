@preconcurrency import AVFoundation
import Domain
import Foundation
import Functor
import Speech

// MARK: - LiveRecorder

@available(iOS 26.0, *)
final actor LiveRecorder {
  private var transcriber: LiveTranscriberV2? = .none
  private let audioEngine = AVAudioEngine()
}

@available(iOS 26.0, *)
extension LiveRecorder {

  func prepare(localeA: Locale, localeB: Locale?) async throws {
    if transcriber != nil { release() }

    try setupSession()
    transcriber = try await setupTranscriber(localeA: localeA, localeB: localeB)
    try await transcriber?.prepare()
  }

  func transcript() -> AsyncThrowingStream<TranscriptionEntity.Item, Error> {
    .init { continuation in
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

@available(iOS 26.0, *)
extension LiveRecorder {
  private func recodeStream() -> AsyncThrowingStream<AVAudioPCMBuffer, Error> {
    .init { continuation in
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
    #if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
    let session = AVAudioSession.sharedInstance()
    try session.setCategory(.playAndRecord, mode: .spokenAudio)
    try session.setActive(true, options: .notifyOthersOnDeactivation)
    #else
    // macOS: AVAudioSession is unavailable; no session setup required.
    #endif
  }

  private func setupTranscriber(localeA: Locale, localeB: Locale?) async throws -> LiveTranscriberV2 {
    await SpeechFunctor(locale: localeA).releaseLocales()
    if let localeB {
      await SpeechFunctor(locale: localeB).releaseLocales()
    }

    return .init(localeA: localeA, localeB: localeB)
  }

  private func setupAudioEngine() throws {
    audioEngine.inputNode.removeTap(onBus: .zero)
  }
}
