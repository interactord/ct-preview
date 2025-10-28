import Domain
import Foundation
import SwiftData

// MARK: - RoomInformationModel

@Model
class RoomInformationModel: Identifiable, IdentifiableModel {

  // MARK: Lifecycle

  init(
    id: String,
    title: String,
    createAt: TimeInterval = Date().timeIntervalSince1970,
    itemListData: Data,
    summery: String?
  ) {
    self.id = id
    self.title = title
    self.createAt = createAt
    _itemListData = itemListData
    self.summery = summery
  }

  convenience init(
    id: String,
    title: String,
    createAt: TimeInterval = Date().timeIntervalSince1970,
    itemList: [TranscriptionEntity.Item],
    summery: String?
  ) {
    self.init(
      id: id,
      title: title,
      createAt: createAt,
      itemListData: itemList.encoded(),
      summery: summery
    )
  }

  // MARK: Internal

  @Attribute(.unique) var id: String

  var title: String
  var createAt: TimeInterval
  var summery: String?

  var itemList: [TranscriptionEntity.Item] {
    get { _itemListData.decoded() }
    set { _itemListData = newValue.encoded() }
  }

  // MARK: Private

  @Attribute(.externalStorage) private var _itemListData = Data()

}

extension [TranscriptionEntity.Item] {
  fileprivate func encoded() -> Data {
    do {
      return try JSONEncoder().encode(self)
    } catch {
      return .init()
    }
  }
}

extension Data {
  fileprivate func decoded() -> [TranscriptionEntity.Item] {
    guard !isEmpty else { return [] }
    let decoder = JSONDecoder()
    do {
      return try decoder.decode([TranscriptionEntity.Item].self, from: self)
    } catch {
      return []
    }
  }
}
