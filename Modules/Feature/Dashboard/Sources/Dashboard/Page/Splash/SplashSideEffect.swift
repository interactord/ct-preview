import Architecture
import ComposableArchitecture
import Domain
import Foundation
import LinkNavigatorSwiftUI

// MARK: - SplashSideEffect

struct SplashSideEffect: Sendable {
  let navigator: SingleNavigator
  let useCaseGroup: DashboardUseCaseGroup
}

extension SplashSideEffect {

  func routeToListeningModePage() -> Effect<SplashReducer.Action> {
    .run { send in
      let path = Link.Dashboard.Path.listeningMode.rawValue
      await navigator.next(item: .init(path: path, items: .none))
//      await navigator.replace(item: .init(path: path, items: .none))
      await send(.none)
    }
  }
}
