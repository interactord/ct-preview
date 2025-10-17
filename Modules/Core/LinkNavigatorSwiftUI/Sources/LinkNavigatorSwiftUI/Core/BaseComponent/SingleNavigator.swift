import Foundation
import SwiftUI

// MARK: - SingleNavigator

@MainActor
@Observable
public final class SingleNavigator: Sendable {

  // MARK: Lifecycle

  public init(
    routeList: [LinkItem] = [],
    dependency: DependencyType,
    routeBuilderList: [RouteBuilderOf<SingleNavigator, AnyView>])
  {
    self.routeList = routeList
    self.dependency = dependency
    self.routeBuilderList = routeBuilderList
  }

  // MARK: Public

  public let dependency: DependencyType
  public var routeBuilderList: [RouteBuilderOf<SingleNavigator, AnyView>]

  public var openWindow: OpenWindowAction?

  // MARK: Internal

  var routeList: [LinkItem] = [] {
    didSet { }
  }

}

extension SingleNavigator {
  public func open(_ item: LinkItem) -> some View {
    let pick = routeBuilderList.first(where: { $0.matchPath == item.pathList.last })
    return pick?.routeBuild(self, item.encodedItemString, dependency)
  }

  public func windowOpen(id: String, value: any Codable & Hashable) {
    openWindow?(id: id, value: value)
  }

  public func windowOpen(id: String) {
    openWindow?(id: id)
  }

  public func next(item: LinkItem) async {
    routeList.append(contentsOf: flatPathList(item))
  }

  public func backOrNext(item: LinkItem) async {
    guard let pickIdx = routeList.firstIndex(where: { ($0.pathList.first ?? "") == item.pathList.first }) else {
      routeList = routeList + flatPathList(item)
      return
    }

    routeList = routeList[0..<pickIdx] + flatPathList(item)
  }

  public func replace(items: [LinkItem]) async {
    routeList = []
    try? await Task.sleep(nanoseconds: 360_000_000)
    routeList = items.flatMap { flatPathList($0) }
  }

  public func replace(item: LinkItem) async {
    routeList = []
    try? await Task.sleep(nanoseconds: 360_000_000)
    routeList = flatPathList(item)
  }

  public func back() {
    routeList = routeList.dropLast()
  }
}

extension SingleNavigator {
  private func flatPathList(_ item: LinkItem) -> [LinkItem] {
    item.pathList.map { .init(path: $0, itemsString: item.encodedItemString, isBase64EncodedItemsString: true) }
  }
}
