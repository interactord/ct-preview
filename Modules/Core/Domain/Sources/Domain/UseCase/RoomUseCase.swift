import Foundation

public protocol RoomUseCase: Sendable {
  func save(roomInformation: RoomInformation) async throws -> RoomInformation
  func update(roomID: String, item: TranscriptionEntity.Item) async throws -> TranscriptionEntity.Item
  func getModelList() async throws -> [RoomInformation]
  func getModel(roomID: String) async throws -> RoomInformation?
  func deleteAll() async throws -> Bool
}
