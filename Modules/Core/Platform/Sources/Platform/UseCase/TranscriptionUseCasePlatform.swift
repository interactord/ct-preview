import Domain
import Foundation

// MARK: - TranscriptionUseCasePlatform

@available(iOS 26.0, *)
public struct TranscriptionUseCasePlatform: Sendable {
  public init(loggingUseCase: LoggingUseCase) {
    self.loggingUseCase = loggingUseCase
  }

  let loggingUseCase: LoggingUseCase
  let actor = LiveRecorder()

}

// MARK: TranscriptionUseCase

@available(iOS 26.0, *)
extension TranscriptionUseCasePlatform: TranscriptionUseCase {
  public func transcript(item: LanguageEntity.Item) async throws -> AsyncThrowingStream<TranscriptionEntity.Item, Error> {
    try await actor.prepare(locale: item.langCode.locale)
    return await actor.transcript()
  }

  public func stop() async throws {
    try await actor.stop()
  }
}
