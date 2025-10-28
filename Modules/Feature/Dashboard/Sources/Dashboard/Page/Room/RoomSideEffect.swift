import Architecture
import ComposableArchitecture
import Domain
import Foundation
import Functor
import LinkNavigatorSwiftUI

// MARK: - RoomSideEffect

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

  func summeryContent(item: RoomInformation) -> Effect<RoomReducer.Action> {
    .run { send in
      guard let locale = item.itemList.first?.translation?.locale
      else { return await send(.none) }

      let content = item.itemList.compactMap { $0.translation?.text }.joined(separator: "\n")

      do {
        let result = try await SummeryModelFunctor().fetch(content: content, locale: locale)
        let newItem = item.mutate(summery: result)
        _ = try await useCaseGroup.roomUseCase.save(roomInformation: newItem)
        await send(.set(\.item, newItem))
      } catch {
        await send(.throwError(error.serialized()))
      }
    }
  }
}

extension RoomInformation {
  fileprivate func mutate(summery: String?) -> RoomInformation {
    var new = self
    new.summery = summery
    return new
  }
}
