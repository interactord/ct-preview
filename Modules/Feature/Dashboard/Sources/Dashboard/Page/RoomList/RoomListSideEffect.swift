import Architecture
import ComposableArchitecture
import Domain
import Foundation
import LinkNavigatorSwiftUI

// MARK: - RoomListSideEffect

struct RoomListSideEffect: Sendable {
  let navigator: SingleNavigator
  let useCaseGroup: DashboardUseCaseGroup
}

extension RoomListSideEffect {

  func getRoomList() -> Effect<RoomListReducer.Action> {
    .run { send in
      let result: Result<[RoomInformation], CompositeError> = await .catching {
        try await useCaseGroup.roomUseCase.getModelList()
      }
      await send(.fetchRoomList(result))
    }
  }

  func deleteAllItem() -> Effect<RoomListReducer.Action> {
    .run { send in
      do {
        _ = try await useCaseGroup.roomUseCase.deleteAll()
        await send(.getRoomList)
      } catch {
        useCaseGroup.loggingUseCase.error(error)
        await send(.none)
      }
    }
  }

  func delete(item: RoomInformation) -> Effect<RoomListReducer.Action> {
    .run { send in
      do {
        _ = try await useCaseGroup.roomUseCase.delete(item: item)
        await send(.getRoomList)
      } catch {
        useCaseGroup.loggingUseCase.error(error)
        await send(.none)
      }
    }
  }

  func routeToRoomDetail(item: RoomInformation) -> Effect<RoomListReducer.Action> {
    .run { send in
      await navigator.next(item: .init(path: Link.Dashboard.Path.room.rawValue, items: item))
      await send(.none)
    }
  }

  func routeToBack() -> Effect<RoomListReducer.Action> {
    .run { send in
      await navigator.back()
      await send(.none)
    }
  }
}
