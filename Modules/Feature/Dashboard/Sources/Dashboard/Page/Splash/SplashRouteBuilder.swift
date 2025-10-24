import Architecture
import ComposableArchitecture
import Foundation
import LinkNavigatorSwiftUI
import SwiftUI

struct SplashRouteBuilder {

  @MainActor
  func generate() -> RouteBuilderOf<SingleNavigator, AnyView> {
    let matchPath = Link.Dashboard.Path.splash.rawValue

    return .init(matchPath: matchPath) { navigator, _, diContainer -> AnyView? in
      guard let env: DashboardUseCaseGroup = diContainer.resolve() else { return .none }
      return AnyView(SplashPage(
        store: .init(
          initialState: SplashReducer.State(),
          reducer: {
            SplashReducer(sideEffect: .init(
              navigator: navigator,
              useCaseGroup: env
            ))
          }
        )
      ))
    }
  }
}
