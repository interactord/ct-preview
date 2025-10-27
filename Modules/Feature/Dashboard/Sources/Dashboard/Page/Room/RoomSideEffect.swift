import Architecture
import ComposableArchitecture
import Domain
import Foundation
import LinkNavigatorSwiftUI

struct RoomSideEffect: Sendable {
  let navigator: SingleNavigator
  let useCaseGroup: DashboardUseCaseGroup
}

extension RoomSideEffect {
  func routeToBack() -> Effect<RoomReducer.Action> {
    .run { send in
      await navigator.replace(item: .init(path: Link.Dashboard.Path.roomList.rawValue, items: .none))
      return await send(.none)
    }
  }
}
