import Foundation

// MARK: - Link.Dashboard

extension Link {
  public enum Dashboard { }
}

// MARK: - Link.Dashboard.Path

extension Link.Dashboard {
  public enum Path: String, Equatable, Sendable {
    case splash = "dashboard-splash"
    case listeningMode = "dashboard-listeningMode"
    case roomList = "dashboard-roomList"
    case room = "dashboard-room"
  }
}

extension Link.Dashboard.Path {
  public var receiver: NotificationCenter.Publisher {
    NotificationCenter.default.publisher(for: .init(rawValue))
  }

  @MainActor
  public func send(_ item: Sendable? = .none) async {
    NotificationCenter.default.post(name: .init(rawValue), object: item)
  }
}
