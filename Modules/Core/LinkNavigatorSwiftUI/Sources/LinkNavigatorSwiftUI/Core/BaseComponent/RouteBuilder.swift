import Foundation
import SwiftUI

// MARK: - MatchPathUsable

public protocol MatchPathUsable {
  var matchPath: String { get }
//  var eventSubscriber: LinkNavigatorItemSubscriberProtocol? { get }
}

// MARK: - RouteBuilderOf

// public typealias WrappingView = MatchPathUsable & NSHostingView<AnyView>

public struct RouteBuilderOf<RootNavigatorType, Content: View> {

  public init(
    matchPath: String,
    routeBuild: @escaping (RootNavigatorType, String, DependencyType) -> Content?
  ) {
    self.matchPath = matchPath
    self.routeBuild = routeBuild
  }

  let matchPath: String
  let routeBuild: (RootNavigatorType, String, DependencyType) -> Content?

}
