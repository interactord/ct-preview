import Domain
import Foundation
import SwiftData

@Model
class RoomInformationModel: Identifiable, IdentifiableModel {

  // MARK: Lifecycle

  init(
    id: String,
    title: String,
    createAt: TimeInterval = Date().timeIntervalSince1970,
    itemListData: Data
  )
  {
    self.id = id
    self.title = title
    self.createAt = createAt
    self._itemListData = itemListData
  }

  convenience init(
    id: String,
    title: String,
    createAt: TimeInterval = Date().timeIntervalSince1970,
    itemList: [TranscriptionEntity.Item]
  )
  {
    self.init(
      id: id,
      title: title,
      createAt: createAt,
      itemListData: itemList.encoded()
    )
  }

  // MARK: Internal

  @Attribute(.unique) var id: String

  var title: String
  var createAt: TimeInterval
  @Attribute(.externalStorage) private var _itemListData: Data = Data()

  var itemList: [TranscriptionEntity.Item] {
    get { _itemListData.decoded() }
    set { _itemListData = newValue.encoded() }
  }
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
