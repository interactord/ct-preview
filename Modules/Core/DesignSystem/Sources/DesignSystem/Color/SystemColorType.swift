import Foundation
import SwiftUI

#if os(macOS)
import AppKit
public typealias UniversalColor = NSColor
#else
import UIKit
public typealias UniversalColor = UIColor
#endif

// MARK: - SystemColorType

public protocol SystemColorType: Sendable {
  var color: Color { get }

  func color(scheme: ColorScheme) -> Color
  func getPaletteColor(scheme: ColorScheme) -> UniversalColor
}

extension SystemColorType {
  public var color: Color {
    // Return a dynamic color that will adapt based on the environment's color scheme
    color(scheme: .light) // This will be overridden by the environment in SwiftUI views
  }

  public func color(scheme: ColorScheme) -> Color {
    Color(getPaletteColor(scheme: scheme))
  }
}

// MARK: - SystemColor

public enum SystemColor: SystemColorType {
  case blue
  case white
  case black
  case inverse
  case grey
  case grey1
  case grey2
  case grey3
  case grey4
  case grey5
  case grey6
  case yellow

  // MARK: Public

  public func getPaletteColor(scheme: ColorScheme) -> UniversalColor {
    switch self {
    case .blue: scheme.isDark ? ColorChip.Blue.color05 : ColorChip.Blue.color05
    case .white: scheme.isDark ? .white : .white
    case .black: scheme.isDark ? .black : .black
    case .inverse: scheme.isDark ? .white : .black
    case .grey: scheme.isDark ? ColorChip.Grey.color40 : ColorChip.Grey.color50
    case .grey1: scheme.isDark ? ColorChip.Grey.color50 : ColorChip.Grey.color40
    case .grey2: scheme.isDark ? ColorChip.Grey.color50 : ColorChip.Grey.color40
    case .grey3: scheme.isDark ? ColorChip.Grey.color60 : ColorChip.Grey.color30
    case .grey4: scheme.isDark ? ColorChip.Grey.color70 : ColorChip.Grey.color20
    case .grey5: scheme.isDark ? ColorChip.Grey.color80 : ColorChip.Grey.color10
    case .grey6: scheme.isDark ? ColorChip.Grey.color90 : ColorChip.Grey.color05
    case .yellow: ColorChip.Yellow.color40
    }
  }
}

extension SystemColor {
  public enum Tint: SystemColorType {
    case red
    case yellow
    case green
    case blue
    case teal

    // MARK: Public

    public func getPaletteColor(scheme _: ColorScheme) -> UniversalColor {
      switch self {
      case .red: ColorChip.Red.color50
      case .yellow: ColorChip.Yellow.color40
      case .green: ColorChip.Green.color50
      case .blue: ColorChip.Blue.color50
      case .teal: ColorChip.Teal.color50
      }
    }
  }

  public enum Background {
    public enum Default: SystemColorType {
      case base
      case elevated

      public func getPaletteColor(scheme: ColorScheme) -> UniversalColor {
        switch self {
        case .base: scheme.isDark ? ColorChip.Grey.color90 : .white
        case .elevated: scheme.isDark ? ColorChip.Grey.color80 : .white
        }
      }
    }

    public enum Grouped: SystemColorType {
      case base
      case upperBase
      case elevated

      // MARK: Public

      public func getPaletteColor(scheme: ColorScheme) -> UniversalColor {
        switch self {
        case .base: scheme.isDark ? .black : ColorChip.Grey.color05
        case .upperBase: scheme.isDark ? ColorChip.Grey.color90 : .white
        case .elevated: scheme.isDark ? ColorChip.Grey.color80 : .white
        }
      }
    }
  }
}

// MARK: SystemColor.Overlay

extension SystemColor {
  public enum Overlay {
    public enum Thick: SystemColorType {
      case `default`
      case disabled

      // MARK: Public

      public func getPaletteColor(scheme: ColorScheme) -> UniversalColor {
        switch self {
        case .default: scheme.isDark
          ? ColorChip.Grey.color70.withAlphaComponent(0.9)
          : ColorChip.Grey.color80.withAlphaComponent(0.9)

        case .disabled: scheme.isDark
          ? ColorChip.Grey.color70.withAlphaComponent(0.37)
          : ColorChip.Grey.color80.withAlphaComponent(0.38)
        }
      }
    }

    public enum Basic: SystemColorType {
      case `default`
      case disabled

      // MARK: Public

      public func getPaletteColor(scheme: ColorScheme) -> UniversalColor {
        switch self {
        case .default:
          scheme.isDark
            ? ColorChip.Grey.color90.withAlphaComponent(0.6)
            : ColorChip.Grey.color90.withAlphaComponent(0.4)

        case .disabled:
          scheme.isDark
            ? ColorChip.Grey.color90.withAlphaComponent(0.24)
            : ColorChip.Grey.color90.withAlphaComponent(0.17)
        }
      }
    }

    public enum Thin: SystemColorType {
      case `default`
      case disabled
      case blue

      // MARK: Public

      public func getPaletteColor(scheme: ColorScheme) -> UniversalColor {
        switch self {
        case .default:
          scheme.isDark
            ? ColorChip.Grey.color70.withAlphaComponent(0.28)
            : ColorChip.Grey.color70.withAlphaComponent(0.05)

        case .disabled:
          scheme.isDark
            ? ColorChip.Grey.color70.withAlphaComponent(0.11)
            : ColorChip.Grey.color70.withAlphaComponent(0.03)

        case .blue:
          scheme.isDark
            ? ColorChip.Blue.color60.withAlphaComponent(0.16)
            : ColorChip.Blue.color20.withAlphaComponent(0.08)
        }
      }
    }

    public enum State: SystemColorType {
      case onBG
      case focus

      // MARK: Public

      public func getPaletteColor(scheme: ColorScheme) -> UniversalColor {
        switch self {
        case .onBG:
          scheme.isDark
            ? ColorChip.Grey.color70.withAlphaComponent(0.18)
            : ColorChip.Grey.color70.withAlphaComponent(0.08)

        case .focus:
          scheme.isDark
            ? ColorChip.Grey.color70.withAlphaComponent(0.3)
            : ColorChip.Grey.color70.withAlphaComponent(0.08)
        }
      }
    }

    public enum OnTint: SystemColorType {
      case hover
      case focus

      // MARK: Public

      public func getPaletteColor(scheme: ColorScheme) -> UniversalColor {
        switch self {
        case .hover:
          scheme.isDark
            ? ColorChip.Grey.color90.withAlphaComponent(0.08)
            : ColorChip.Grey.color90.withAlphaComponent(0.08)

        case .focus:
          scheme.isDark
            ? ColorChip.Grey.color90.withAlphaComponent(0.12)
            : ColorChip.Grey.color90.withAlphaComponent(0.12)
        }
      }
    }
  }
}

// MARK: SystemColor.Label

extension SystemColor {
  public enum Label {
    public enum OnBG: SystemColorType {
      case primary
      case Secondary
      case tertiary

      // MARK: Public

      public func getPaletteColor(scheme: ColorScheme) -> UniversalColor {
        switch self {
        case .primary:
          scheme.isDark
            ? ColorChip.Grey.color05
            : ColorChip.Grey.color90

        case .Secondary:
          scheme.isDark
            ? ColorChip.Grey.color05.withAlphaComponent(0.57)
            : ColorChip.Grey.color90.withAlphaComponent(0.6)

        case .tertiary:
          scheme.isDark
            ? ColorChip.Grey.color05.withAlphaComponent(0.3)
            : ColorChip.Grey.color90.withAlphaComponent(0.29)
        }
      }
    }

    public enum OnTint: SystemColorType {
      case primary
      case secondary
      case tertiary

      // MARK: Public

      public func getPaletteColor(scheme: ColorScheme) -> UniversalColor {
        switch self {
        case .primary:
          scheme.isDark
            ? ColorChip.Grey.color90
            : ColorChip.Grey.color05

        case .secondary:
          scheme.isDark
            ? ColorChip.Grey.color90.withAlphaComponent(0.57)
            : ColorChip.Grey.color05.withAlphaComponent(0.6)

        case .tertiary:
          scheme.isDark
            ? ColorChip.Grey.color90.withAlphaComponent(0.29)
            : ColorChip.Grey.color05.withAlphaComponent(0.3)
        }
      }
    }
  }
}

// MARK: SystemColor.Separator

extension SystemColor {
  public enum Separator: SystemColorType {
    case nonOpaque

    public func getPaletteColor(scheme: ColorScheme) -> UniversalColor {
      switch self {
      case .nonOpaque:
        scheme.isDark
          ? ColorChip.Grey.color05.withAlphaComponent(0.1)
          : ColorChip.Grey.color90.withAlphaComponent(0.08)
      }
    }
  }
}

// MARK: SystemColor.BrandColor

extension SystemColor {
  public enum BrandColor {
    public enum Primary: SystemColorType {
      case blue
      case red
      case orange
      case yellow
      case green
      case mint
      case navy
      case violet
      case indigo

      // MARK: Public

      public func getPaletteColor(scheme _: ColorScheme) -> UniversalColor {
        switch self {
        case .blue:
          ColorChip.BrandColor.blue
        case .red:
          ColorChip.BrandColor.red
        case .orange:
          ColorChip.BrandColor.orange
        case .yellow:
          ColorChip.BrandColor.yellow
        case .green:
          ColorChip.BrandColor.green
        case .mint:
          ColorChip.BrandColor.mint
        case .navy:
          ColorChip.BrandColor.navy
        case .violet:
          ColorChip.BrandColor.violet
        case .indigo:
          ColorChip.BrandColor.indigo
        }
      }
    }
  }
}

extension ColorScheme {
  fileprivate var isDark: Bool {
    switch self {
    case .light: false
    case .dark: true
    @unknown default: false
    }
  }
}
