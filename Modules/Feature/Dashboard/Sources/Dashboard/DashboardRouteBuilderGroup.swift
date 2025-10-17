import Architecture
import LinkNavigatorSwiftUI
import SwiftUI

// MARK: - DashboardRouteBuilderGroup

public struct DashboardRouteBuilderGroup {
  public init() { }
}

extension DashboardRouteBuilderGroup {
  @MainActor
  public func release() -> [RouteBuilderOf<SingleNavigator, AnyView>] {
    [
      SplashRouteBuilder().generate(),
//      LoginRouteBuilder().generate(),
//      RoomListRouteBuilder().generate(),
//      SpeechRoomRouteBuilder().generate(),
//      CreateRoomBuilder().generate(),
    ]
  }
}
