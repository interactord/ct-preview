import Architecture
import ComposableArchitecture
import Foundation
import LinkNavigatorSwiftUI
import SwiftUI

struct RoomListRouteBuilder {

  @MainActor
  func generate() -> RouteBuilderOf<SingleNavigator, AnyView> {
    let matchPath = Link.Dashboard.Path.roomList.rawValue

    return .init(matchPath: matchPath) { navigator, _, diContainer -> AnyView? in
      guard let env: DashboardUseCaseGroup = diContainer.resolve() else { return .none }
      return AnyView(RoomListPage(
        store: .init(
          initialState: RoomListReducer.State(),
          reducer: {
            RoomListReducer(sideEffect: .init(
              navigator: navigator,
              useCaseGroup: env
            ))
          }
        )
      ))
    }
  }
}
