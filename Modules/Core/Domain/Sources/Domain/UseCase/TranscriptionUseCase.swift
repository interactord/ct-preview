import Foundation

public protocol TranscriptionUseCase: Sendable {
  func transcript(item: LanguageEntity.Item) async throws -> AsyncThrowingStream<TranscriptionEntity.Item, Error>
  func stop() async throws
}
