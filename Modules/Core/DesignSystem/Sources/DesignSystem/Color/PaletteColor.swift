import Foundation
import SwiftUI

// MARK: - PaletteColorType

protocol PaletteColorType {
  static var color05: Color { get }
  static var color10: Color { get }
  static var color20: Color { get }
  static var color30: Color { get }
  static var color40: Color { get }
  static var color50: Color { get }
  static var color60: Color { get }
  static var color70: Color { get }
  static var color80: Color { get }
  static var color90: Color { get }
}

// MARK: - PaletteColor

public enum PaletteColor {
  struct Grey: PaletteColorType {
    public static let color05 = Color(.grey05)
    public static let color10 = Color(.grey10)
    public static let color20 = Color(.grey20)
    public static let color30 = Color(.grey30)
    public static let color40 = Color(.grey40)
    public static let color50 = Color(.grey50)
    public static let color60 = Color(.grey60)
    public static let color70 = Color(.grey70)
    public static let color80 = Color(.grey80)
    public static let color90 = Color(.grey90)
  }

  struct Blue: PaletteColorType {
    public static let color05 = Color(.blue05)
    public static let color10 = Color(.blue10)
    public static let color20 = Color(.blue20)
    public static let color30 = Color(.blue30)
    public static let color40 = Color(.blue40)
    public static let color50 = Color(.blue50)
    public static let color60 = Color(.blue60)
    public static let color70 = Color(.blue70)
    public static let color80 = Color(.blue80)
    public static let color90 = Color(.blue90)
  }

  struct Red: PaletteColorType {
    public static let color05 = Color(.red05)
    public static let color10 = Color(.red10)
    public static let color20 = Color(.red20)
    public static let color30 = Color(.red30)
    public static let color40 = Color(.red40)
    public static let color50 = Color(.red50)
    public static let color60 = Color(.red60)
    public static let color70 = Color(.red70)
    public static let color80 = Color(.red80)
    public static let color90 = Color(.red90)
  }

  struct Teal: PaletteColorType {
    public static let color05 = Color(.mint05)
    public static let color10 = Color(.mint10)
    public static let color20 = Color(.mint20)
    public static let color30 = Color(.mint30)
    public static let color40 = Color(.mint40)
    public static let color50 = Color(.mint50)
    public static let color60 = Color(.mint60)
    public static let color70 = Color(.mint70)
    public static let color80 = Color(.mint80)
    public static let color90 = Color(.mint90)
  }

  struct Green: PaletteColorType {
    public static let color05 = Color(.green05)
    public static let color10 = Color(.green10)
    public static let color20 = Color(.green20)
    public static let color30 = Color(.green30)
    public static let color40 = Color(.green40)
    public static let color50 = Color(.green50)
    public static let color60 = Color(.green60)
    public static let color70 = Color(.green70)
    public static let color80 = Color(.green80)
    public static let color90 = Color(.green90)
  }

  struct Yellow: PaletteColorType {
    public static let color05 = Color(.yellow05)
    public static let color10 = Color(.yellow10)
    public static let color20 = Color(.yellow20)
    public static let color30 = Color(.yellow30)
    public static let color40 = Color(.yellow40)
    public static let color50 = Color(.yellow50)
    public static let color60 = Color(.yellow60)
    public static let color70 = Color(.yellow70)
    public static let color80 = Color(.yellow80)
    public static let color90 = Color(.yellow90)
  }

  enum ColorLevelChip {
    public static let mid = ColorChip.Green.color70
    public static let high = #colorLiteral(red: 0, green: 0.5294117647, blue: 0.8784313725, alpha: 1)
    public static let fluent = #colorLiteral(red: 0.2392156863, green: 0.4, blue: 0.937254902, alpha: 1)
  }
}
