import Architecture
import ComposableArchitecture
import Foundation
import LinkNavigatorSwiftUI
import SwiftUI

struct ListeningModeRouteBuilder {

  @MainActor
  func generate() -> RouteBuilderOf<SingleNavigator, AnyView> {
    let matchPath = Link.Dashboard.Path.listeningMode.rawValue

    return .init(matchPath: matchPath) { navigator, _, diContainer -> AnyView? in
      guard let env: DashboardUseCaseGroup = diContainer.resolve() else { return .none }
      return AnyView(ListeningModePage(
        store: .init(
          initialState: ListeningModeReducer.State(),
          reducer: {
            ListeningModeReducer(sideEffect: .init(
              navigator: navigator,
              useCaseGroup: env))
          })))
    }
  }
}
