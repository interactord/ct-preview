import Foundation

public protocol TranscriptionUseCase: Sendable {
  func transcript(itemA: LanguageEntity.Item, itemB: LanguageEntity.Item?) async throws -> AsyncThrowingStream<TranscriptionEntity.Item, Error>
  func stop() async throws
}
