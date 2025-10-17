import Foundation
import SwiftUI
#if os(macOS)
import AppKit
#endif

// MARK: - SystemColorChip

struct SystemColorChip {
  let systemColor: SystemColorType

  init(systemColor: SystemColorType) {
    self.systemColor = systemColor
  }
}

// MARK: View

extension SystemColorChip {
  public var color: Color {
    #if os(macOS)
    return .init(nsColor: NSColor(name: .none, dynamicProvider: { appearance in
      switch appearance.name {
      case .aqua,
           .vibrantLight,
           .accessibilityHighContrastAqua,
           .accessibilityHighContrastVibrantLight:
        systemColor.getPaletteColor(scheme: ColorScheme.light)
      case .darkAqua,
           .vibrantDark,
           .accessibilityHighContrastDarkAqua,
           .accessibilityHighContrastVibrantDark:
        systemColor.getPaletteColor(scheme: ColorScheme.dark)
      default: systemColor.getPaletteColor(scheme: ColorScheme.light)
      }
    }))
    #else
    // For iOS/other platforms, return the color directly
    return systemColor.color
    #endif
  }
}

// MARK: ShapeStyle

extension SystemColorChip: ShapeStyle {
  public func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
    systemColor.color(scheme: environment.colorScheme)
  }
}
