import Foundation
import Speech

// MARK: - SpeechFunctor

@available(iOS 26.0, *)
public struct SpeechFunctor: Sendable {

  // MARK: Lifecycle

  public init(locale: Locale) {
    self.locale = locale
    module = SpeechTranscriber(locale: locale, preset: SpeechTranscriber.Preset.default)
  }

  // MARK: Public

  public func getModelStatus() async -> SpeechStatus {
    guard !isRunningOnSimulator else { return .notSupported }
    return await installed(locale: locale) ? .installed : .notInstalled
  }

  public func downloadIfNeeded() -> AsyncThrowingStream<Double, Error> {
    .init { continuation in
      Task {
        do {
          guard let downloader = try await AssetInventory.assetInstallationRequest(supporting: [module]) else {
//            print("[ERRROR] module install Null")
            continuation.finish()
            return
          }

          let progress = downloader.progress
          continuation.yield(progress.fractionCompleted)

          Task {
            while !downloader.progress.isFinished {
              continuation.yield(downloader.progress.fractionCompleted)
              try? await Task.sleep(for: .seconds(0.1))
            }
          }

          // Start download and install
          try await downloader.downloadAndInstall()

          // yield 1.0 to indicate completion
          continuation.yield(1.0)
          continuation.finish()
        } catch {
          continuation.finish(throwing: error)
        }
      }
    }
  }

  public func releaseLocales() async {
    let reserved = await AssetInventory.reservedLocales
    for locale in reserved {
      await AssetInventory.release(reservedLocale: locale)
    }
  }

  public func installed(locale: Locale) async -> Bool {
    let installed = await Set(SpeechTranscriber.installedLocales)
    return installed.map { $0.identifier(.bcp47) }.contains(locale.identifier(.bcp47))
  }

  // MARK: Internal

  let locale: Locale

  // MARK: Private

  private let module: SpeechTranscriber

  private var isRunningOnSimulator: Bool {
    #if targetEnvironment(simulator)
    return true
    #else
    return false
    #endif
  }

}

@available(iOS 26.0, *)
extension SpeechFunctor {

  // MARK: Public

  public enum SpeechStatus {
    case installed
    case notInstalled
    case notSupported
  }

  // MARK: Private

  private func supported(locale: Locale) async -> Bool {
    let supported = await SpeechTranscriber.supportedLocales
    return supported.map { $0.identifier(.bcp47) }.contains(locale.identifier(.bcp47))
  }

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
