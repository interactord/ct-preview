import Architecture
import ComposableArchitecture
import Foundation
import LinkNavigatorSwiftUI
import SwiftUI
import Domain

struct RoomRouteBuilder {

  @MainActor
  func generate() -> RouteBuilderOf<SingleNavigator, AnyView> {
    let matchPath = Link.Dashboard.Path.room.rawValue

    return .init(matchPath: matchPath) { navigator, items, diContainer -> AnyView? in
      guard let env: DashboardUseCaseGroup = diContainer.resolve() else { return .none }
      guard let item: RoomInformation = items.decoded() else { return .none }
      
      return AnyView(RoomPage(
        store: .init(
          initialState: RoomReducer.State(item: item),
          reducer: {
            RoomReducer(sideEffect: .init(
              navigator: navigator,
              useCaseGroup: env
            ))
          }
        )
      ))
    }
  }
}
