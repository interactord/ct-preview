import Foundation
import SwiftUI

#if os(macOS)
public typealias UniversalFontWeight = NSFont.Weight
#else
public typealias UniversalFontWeight = UIFont.Weight
#endif

// MARK: - FontWeight

public enum FontWeight: Equatable {
  case regular
  case bold

  public var uiRawValue: UniversalFontWeight {
    switch self {
    case .regular: .regular
    case .bold: .bold
    }
  }

  public var rawValue: Font.Weight {
    switch self {
    case .regular: .regular
    case .bold: .bold
    }
  }
}
