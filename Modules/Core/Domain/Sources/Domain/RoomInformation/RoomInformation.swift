import Foundation

public struct RoomInformation: Equatable, Sendable, Identifiable, Codable {

  // MARK: Lifecycle

  public init(
    id: String,
    title: String,
    createAt: TimeInterval,
    itemList: [TranscriptionEntity.Item],
    summery: String?
  ) {
    self.id = id
    self.title = title
    self.createAt = createAt
    self.itemList = itemList
    self.summery = summery
  }

  // MARK: Public

  public let id: String
  public var title: String
  public var createAt: TimeInterval
  public var itemList: [TranscriptionEntity.Item]
  public var summery: String?

}
