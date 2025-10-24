import Foundation

public struct EquatableAction: Equatable {
  public init(action: @escaping () -> Void) {
    self.action = action
  }

  public let action: () -> Void

  public static func ==(lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id
  }

  private let id = UUID()

}
