import Foundation
import SwiftUI

public enum FontSize: Equatable {
  case font48
  case font36
  case font32
  case font28
  case font24
  case font18
  case font16
  case font14
  case font12
  case font11
  case custom(CGFloat)

  // MARK: Public

  public var rawValue: CGFloat {
    switch self {
    case .font48: 48
    case .font36: 36
    case .font32: 32
    case .font28: 28
    case .font24: 24
    case .font18: 18
    case .font16: 16
    case .font14: 14
    case .font12: 12
    case .font11: 11
    case .custom(let value): value
    }
  }
}
