import Foundation

public struct RoomInformation: Equatable, Sendable, Identifiable, Codable {
  public let id: String
  public var title: String
  public var createAt: TimeInterval
  public var itemList: [TranscriptionEntity.Item]

  public init(
    id: String,
    title: String,
    createAt: TimeInterval,
    itemList: [TranscriptionEntity.Item])
  {
    self.id = id
    self.title = title
    self.createAt = createAt
    self.itemList = itemList
  }
}
