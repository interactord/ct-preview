import Foundation
import Domain



public struct TranscriptionUseCasePlatform: Sendable {
  let loggingUseCase: LoggingUseCase
  let actor: LiveRecorder = .init()

  public init(loggingUseCase: LoggingUseCase) {
    self.loggingUseCase = loggingUseCase
  }
}

extension TranscriptionUseCasePlatform: TranscriptionUseCase {
  public func transcript(item: LanguageEntity.Item) async throws -> AsyncThrowingStream<TranscriptionEntity.Item, Error> {
    try await actor.prepare(locale: item.langCode.locale)
    return await actor.transcript()
  }

  public func stop() async throws {
    try await actor.stop()
  }
}
