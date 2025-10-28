import Domain
import Foundation
import SwiftData

// MARK: - RoomUseCasePlatform

public struct RoomUseCasePlatform: Sendable {

  @MainActor
  public init(loggingUseCase: LoggingUseCase) {
    self.loggingUseCase = loggingUseCase

    let schema = Schema([
      RoomInformationModel.self
    ])

    dbManager = .init(
      schema: schema,
      modelConfiguration: .init(
        schema: schema,
        isStoredInMemoryOnly: false
      )
    )
  }

  let loggingUseCase: LoggingUseCase
  let dbManager: DatabaseManagerPlatform
}

// MARK: RoomUseCase

extension RoomUseCasePlatform: RoomUseCase {
  @MainActor
  public func save(roomInformation: RoomInformation) async throws -> RoomInformation {
    _ = try dbManager.save(model: roomInformation.serialized())
    return roomInformation
  }

  @MainActor
  public func update(roomID: String, item: TranscriptionEntity.Item) async throws -> TranscriptionEntity.Item {
    guard let pick: RoomInformationModel = try dbManager.fetch(id: roomID) else { return item }
    if let pickID = pick.itemList.lastIndex(where: { $0.id == item.id }) {
      pick.itemList[pickID] = item
    } else {
      pick.itemList.append(item)
    }
    _ = try dbManager.save(model: pick)

    return item
  }

  @MainActor
  public func getModelList() async throws -> [RoomInformation] {
    let list = try dbManager.fetchList(sort: \RoomInformationModel.createAt, ascending: true)
    return list.map { $0.serialized() }
  }

  @MainActor
  public func getModel(roomID: String) async throws -> RoomInformation? {
    let item: RoomInformationModel? = try dbManager.fetch(id: roomID)
    return item?.serialized()
  }

  @MainActor
  public func deleteAll() async throws -> Bool {
    try dbManager.deleteAll(type: RoomInformationModel.self)
  }

  @MainActor
  public func delete(item: RoomInformation) async throws -> Bool {
    _ = try dbManager.delete(type: RoomInformationModel.self, id: item.id)
    return true
  }
}

extension RoomInformation {
  fileprivate func serialized() -> RoomInformationModel {
    .init(id: id, title: title, createAt: createAt, itemList: itemList, summery: summery)
  }
}

extension RoomInformationModel {
  fileprivate func serialized() -> RoomInformation {
    .init(id: id, title: title, createAt: createAt, itemList: itemList, summery: summery)
  }
}
