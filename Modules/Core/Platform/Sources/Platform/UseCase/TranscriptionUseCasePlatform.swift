import Domain
import Foundation

// MARK: - TranscriptionUseCasePlatform

@available(iOS 26.0, *)
public struct TranscriptionUseCasePlatform: Sendable {
  public init(loggingUseCase: LoggingUseCase) {
    self.loggingUseCase = loggingUseCase
  }

  let loggingUseCase: LoggingUseCase
  let liveRecorder = LiveRecorder()

}

// MARK: TranscriptionUseCase

@available(iOS 26.0, *)
extension TranscriptionUseCasePlatform: TranscriptionUseCase {
  public func transcript(itemA: LanguageEntity.Item, itemB: LanguageEntity.Item?) async throws -> AsyncThrowingStream<TranscriptionEntity.Item, Error> {
    try await liveRecorder.prepare(localeA: itemA.langCode.locale, localeB: itemB?.langCode.locale)
    return await liveRecorder.transcript()
  }

  public func stop() async throws {
    try await liveRecorder.stop()
  }
}
