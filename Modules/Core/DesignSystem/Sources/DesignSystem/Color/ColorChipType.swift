import SwiftUI

#if os(macOS)
import AppKit
#else
import UIKit
#endif

// MARK: - ColorChipType

protocol ColorChipType {
  static var color05: UniversalColor { get }
  static var color10: UniversalColor { get }
  static var color20: UniversalColor { get }
  static var color30: UniversalColor { get }
  static var color40: UniversalColor { get }
  static var color50: UniversalColor { get }
  static var color60: UniversalColor { get }
  static var color70: UniversalColor { get }
  static var color80: UniversalColor { get }
  static var color90: UniversalColor { get }
}

// MARK: - ColorChip

enum ColorChip {
  struct Grey: ColorChipType {
    static let color05 = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
    static let color10 = #colorLiteral(red: 0.925, green: 0.925, blue: 0.925, alpha: 0.925)
    static let color20 = #colorLiteral(red: 0.8745098039, green: 0.8745098039, blue: 0.8745098039, alpha: 1)
    static let color30 = #colorLiteral(red: 0.8117647059, green: 0.8117647059, blue: 0.8117647059, alpha: 1)
    static let color40 = #colorLiteral(red: 0.737254902, green: 0.737254902, blue: 0.737254902, alpha: 1)
    static let color50 = #colorLiteral(red: 0.6470588235, green: 0.6470588235, blue: 0.6470588235, alpha: 1)
    static let color60 = #colorLiteral(red: 0.5411764706, green: 0.5411764706, blue: 0.5411764706, alpha: 1)
    static let color70 = #colorLiteral(red: 0.3529411765, green: 0.3529411765, blue: 0.3529411765, alpha: 1)
    static let color80 = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    static let color90 = #colorLiteral(red: 0.1019607843, green: 0.1019607843, blue: 0.1019607843, alpha: 1)
  }

  struct Blue: ColorChipType {
    static let color05 = #colorLiteral(red: 0.9411764706, green: 0.9647058824, blue: 1, alpha: 1)
    static let color10 = #colorLiteral(red: 0.737254902, green: 0.8549019608, blue: 1, alpha: 1)
    static let color20 = #colorLiteral(red: 0.537254902, green: 0.7411764706, blue: 1, alpha: 1)
    static let color30 = #colorLiteral(red: 0.3607843137, green: 0.6352941176, blue: 1, alpha: 1)
    static let color40 = #colorLiteral(red: 0.2078431373, green: 0.5450980392, blue: 0.9803921569, alpha: 1)
    static let color50 = #colorLiteral(red: 0.09019607843, green: 0.462745098, blue: 0.9450980392, alpha: 1)
    static let color60 = #colorLiteral(red: 0, green: 0.3921568627, blue: 0.8980392157, alpha: 1)
    static let color70 = #colorLiteral(red: 0.01568627451, green: 0.3490196078, blue: 0.7843137255, alpha: 1)
    static let color80 = #colorLiteral(red: 0.03529411765, green: 0.3058823529, blue: 0.6588235294, alpha: 1)
    static let color90 = #colorLiteral(red: 0.05490196078, green: 0.2588235294, blue: 0.5294117647, alpha: 1)
  }

  struct Red: ColorChipType {
    static let color05 = #colorLiteral(red: 1, green: 0.9529411765, blue: 0.9529411765, alpha: 1)
    static let color10 = #colorLiteral(red: 1, green: 0.7725490196, blue: 0.7568627451, alpha: 1)
    static let color20 = #colorLiteral(red: 1, green: 0.5882352941, blue: 0.5647058824, alpha: 1)
    static let color30 = #colorLiteral(red: 1, green: 0.4235294118, blue: 0.3921568627, alpha: 1)
    static let color40 = #colorLiteral(red: 0.9843137255, green: 0.2862745098, blue: 0.2470588235, alpha: 1)
    static let color50 = #colorLiteral(red: 0.9215686275, green: 0.2039215686, blue: 0.1647058824, alpha: 1)
    static let color60 = #colorLiteral(red: 0.8431372549, green: 0.1490196078, blue: 0.1098039216, alpha: 1)
    static let color70 = #colorLiteral(red: 0.7490196078, green: 0.1098039216, blue: 0.07450980392, alpha: 1)
    static let color80 = #colorLiteral(red: 0.6431372549, green: 0.0862745098, blue: 0.05490196078, alpha: 1)
    static let color90 = #colorLiteral(red: 0.5294117647, green: 0.07058823529, blue: 0.04705882353, alpha: 1)
  }

  struct Teal: ColorChipType {
    static let color05 = #colorLiteral(red: 0.9176470588, green: 0.9843137255, blue: 0.9725490196, alpha: 1)
    static let color10 = #colorLiteral(red: 0.8392156863, green: 0.9725490196, blue: 0.9490196078, alpha: 1)
    static let color20 = #colorLiteral(red: 0.6509803922, green: 0.9411764706, blue: 0.8901960784, alpha: 1)
    static let color30 = #colorLiteral(red: 0.4862745098, green: 0.8941176471, blue: 0.8274509804, alpha: 1)
    static let color40 = #colorLiteral(red: 0.3568627451, green: 0.8352941176, blue: 0.7568627451, alpha: 1)
    static let color50 = #colorLiteral(red: 0.262745098, green: 0.7568627451, blue: 0.6745098039, alpha: 1)
    static let color60 = #colorLiteral(red: 0.1921568627, green: 0.6588235294, blue: 0.5803921569, alpha: 1)
    static let color70 = #colorLiteral(red: 0.1764705882, green: 0.5333333333, blue: 0.4745098039, alpha: 1)
    static let color80 = #colorLiteral(red: 0.09019607843, green: 0.4117647059, blue: 0.3607843137, alpha: 1)
    static let color90 = #colorLiteral(red: 0.03137254902, green: 0.2745098039, blue: 0.231372549, alpha: 1)
  }

  struct Green: ColorChipType {
    static let color05 = #colorLiteral(red: 0.9019607843, green: 0.9607843137, blue: 0.8980392157, alpha: 1)
    static let color10 = #colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.7490196078, alpha: 1)
    static let color20 = #colorLiteral(red: 0.6196078431, green: 0.8392156863, blue: 0.5843137255, alpha: 1)
    static let color30 = #colorLiteral(red: 0.4588235294, green: 0.7803921569, blue: 0.4117647059, alpha: 1)
    static let color40 = #colorLiteral(red: 0.3294117647, green: 0.7333333333, blue: 0.2784313725, alpha: 1)
    static let color50 = #colorLiteral(red: 0.1803921569, green: 0.6862745098, blue: 0.1137254902, alpha: 1)
    static let color60 = #colorLiteral(red: 0.1333333333, green: 0.6274509804, blue: 0.07058823529, alpha: 1)
    static let color70 = #colorLiteral(red: 0.05490196078, green: 0.5568627451, blue: 0, alpha: 1)
    static let color80 = #colorLiteral(red: 0, green: 0.4901960784, blue: 0, alpha: 1)
    static let color90 = #colorLiteral(red: 0, green: 0.3725490196, blue: 0, alpha: 1)
  }

  struct Yellow: ColorChipType {
    static let color05 = #colorLiteral(red: 1, green: 0.9764705882, blue: 0.9058823529, alpha: 1)
    static let color10 = #colorLiteral(red: 1, green: 0.9490196078, blue: 0.8117647059, alpha: 1)
    static let color20 = #colorLiteral(red: 1, green: 0.8823529412, blue: 0.6117647059, alpha: 1)
    static let color30 = #colorLiteral(red: 1, green: 0.8117647059, blue: 0.4352941176, alpha: 1)
    static let color40 = #colorLiteral(red: 0.9843137255, green: 0.7411764706, blue: 0.2823529412, alpha: 1)
    static let color50 = #colorLiteral(red: 0.9176470588, green: 0.662745098, blue: 0.1725490196, alpha: 1)
    static let color60 = #colorLiteral(red: 0.8392156863, green: 0.5843137255, blue: 0.09411764706, alpha: 1)
    static let color70 = #colorLiteral(red: 0.7411764706, green: 0.5019607843, blue: 0.0431372549, alpha: 1)
    static let color80 = #colorLiteral(red: 0.6235294118, green: 0.4156862745, blue: 0.01568627451, alpha: 1)
    static let color90 = #colorLiteral(red: 0.4941176471, green: 0.3294117647, blue: 0, alpha: 1)
  }

  enum ColorLevelChip {
    static let mid = ColorChip.Green.color70
    static let high = #colorLiteral(red: 0, green: 0.5294117647, blue: 0.8784313725, alpha: 1)
    static let fluent = #colorLiteral(red: 0.2392156863, green: 0.4, blue: 0.937254902, alpha: 1)
  }
}

// MARK: ColorChip.BrandColor

extension ColorChip {
  enum BrandColor {
    static let blue = #colorLiteral(red: 0.09552114457, green: 0.4697247148, blue: 0.9410867095, alpha: 1)
    static let red = #colorLiteral(red: 0.9199217558, green: 0.2057336271, blue: 0.1667225361, alpha: 1)
    static let orange = #colorLiteral(red: 0.960519135, green: 0.4137281179, blue: 0.1760847867, alpha: 1)
    static let yellow = #colorLiteral(red: 0.986916244, green: 0.7389953732, blue: 0.2817969918, alpha: 1)
    static let green = #colorLiteral(red: 0.1353191733, green: 0.6287114024, blue: 0.06439584494, alpha: 1)
    static let mint = #colorLiteral(red: 0.2652418613, green: 0.7551901937, blue: 0.672499001, alpha: 1)
    static let navy = #colorLiteral(red: 0.07616258413, green: 0.1389015019, blue: 0.2596291602, alpha: 1)
    static let violet = #colorLiteral(red: 0.646882534, green: 0.2534300983, blue: 0.6459681392, alpha: 1)
    static let indigo = #colorLiteral(red: 0.4228342175, green: 0.2967509031, blue: 0.8539238572, alpha: 1)
  }
}
