import Foundation

public struct EquatableAction: Equatable {
  private let id = UUID()
  public let action: () -> Void

  public init(action: @escaping () -> Void) {
    self.action = action
  }

  public static func ==(lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id
  }
}
