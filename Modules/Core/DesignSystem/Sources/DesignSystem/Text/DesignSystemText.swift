import Foundation
import SwiftUI

// MARK: - DesignSystemText

public struct DesignSystemText: View {

  // MARK: Lifecycle

  public init(
    text: String?,
    backgroundColor: Color? = .none,
    textModel: DesignSystemTextModel = .defaultModel
  ) {
    self.text = text
    self.backgroundColor = backgroundColor
    self.textModel = textModel
  }

  // MARK: Public

  public var body: some View {
    if !(text?.isEmpty ?? true) {
      textObject
    } else {
      EmptyView()
    }
  }

  public var textObject: Text {
    Text.serialized(rawValue: text?.covertWhiteSpace ?? "", backgroundColor: backgroundColor)
      .foregroundColor(textModel.color)
      .fontWeight(textModel.weight.rawValue)
      .font(.system(size: textModel.fontSize.rawValue))
      .underline(textModel.underline.isShow, color: textModel.underline.color)
  }

  // MARK: Internal

  @Environment(\.fontScale) var fontScale: CGFloat

  let text: String?
  let backgroundColor: Color?
  let textModel: DesignSystemTextModel

}

// MARK: - TextViewPreview

struct TextViewPreview: PreviewProvider {
  static var previews: some View {
    DesignSystemText(text: "TEXT TEXT TEXT TEXT TEXT TEXT TEXT TEXT TEXT TEXT TEXT TEXT")
  }
}

extension DesignSystemText {
  public func mutate(textModel: DesignSystemTextModel) -> Self {
    .init(text: text, backgroundColor: backgroundColor, textModel: textModel)
  }

  public func setFontSize(fontSize: FontSize) -> Self {
    let textModel = DesignSystemTextModel(
      color: textModel.color,
      fontSize: fontSize,
      weight: textModel.weight,
      underline: textModel.underline
    )

    return mutate(textModel: textModel)
  }

  public func setFontWeight(fontWeight: FontWeight) -> Self {
    let textModel = DesignSystemTextModel(
      color: textModel.color,
      fontSize: textModel.fontSize,
      weight: fontWeight,
      underline: textModel.underline
    )

    return mutate(textModel: textModel)
  }

  public func setFontColor(fontColor: Color) -> Self {
    let textModel = DesignSystemTextModel(
      color: fontColor,
      fontSize: textModel.fontSize,
      weight: textModel.weight,
      underline: textModel.underline
    )

    return mutate(textModel: textModel)
  }

  public func setUnderLine(underline: DesignSystemTextModel.UnderLineStyle) -> Self {
    let textModel = DesignSystemTextModel(
      color: textModel.color,
      fontSize: textModel.fontSize,
      weight: textModel.weight,
      underline: underline
    )

    return mutate(textModel: textModel)
  }
}

// MARK: - DesignSystemTextModel

public struct DesignSystemTextModel {
  public init(
    color: Color,
    fontSize: FontSize,
    weight: FontWeight,
    underline: UnderLineStyle = .none
  ) {
    self.color = color
    self.fontSize = fontSize
    self.weight = weight
    self.underline = underline
  }

  let color: Color
  let fontSize: FontSize
  let weight: FontWeight
  let underline: UnderLineStyle

}

extension DesignSystemTextModel {
  public static var defaultModel: Self {
    .init(
      color: SystemColor.Label.OnBG.primary.color,
      fontSize: .font16,
      weight: .regular,
      underline: .none
    )
  }
}

// MARK: DesignSystemTextModel.UnderLineStyle

extension DesignSystemTextModel {
  public enum UnderLineStyle {
    case none
    case color(Color)

    var isShow: Bool {
      switch self {
      case .none: false
      default: true
      }
    }

    var color: Color? {
      switch self {
      case .none: .none
      case .color(let value): value
      }
    }
  }
}

// MARK: - ReplacingText

struct ReplacingText: ViewModifier {

  // MARK: Lifecycle

  init(
    text: String?,
    replaceFor: String,
    textModel: DesignSystemTextModel,
    content: @escaping () -> Text
  ) {
    self.text = text
    self.replaceFor = replaceFor
    self.textModel = textModel
    self.content = content
  }

  // MARK: Internal

  let text: String?
  let replaceFor: String
  let textModel: DesignSystemTextModel
  let content: () -> Text

  func build(text: String?) -> some View {
    if let text, text.contains(replaceFor) {
      return text.split(separatedBy: replaceFor).reduce(Text("")) {
        replaceFor != $1 ? $0 + buildOrigin(text: $1) : $0 + content()
      }
    } else {
      return buildOrigin(text: text)
    }
  }

  func buildOrigin(text: String?) -> Text {
    Text(text ?? "")
      .foregroundColor(textModel.color)
      .fontWeight(textModel.weight.rawValue)
      .font(.system(size: textModel.fontSize.rawValue))
      .underline(textModel.underline.isShow, color: textModel.underline.color)
  }

  func body(content _: Content) -> some View {
    build(text: text)
  }
}

extension DesignSystemText {
  public func replacingString(
    replaceFor: String,
    content: @escaping () -> Text
  ) -> some View {
    modifier(ReplacingText(text: text, replaceFor: replaceFor, textModel: textModel, content: content))
  }
}

extension String {
  fileprivate func split(separatedBy: String) -> [String] {
    let items = components(separatedBy: separatedBy)
    switch items.count {
    case 0:
      return [self]
    case 1:
      return [self + separatedBy]
    default:
      return items.enumerated().reduce([]) { current, next in
        guard next.offset < items.count - 1 else {
          return current + [next.element]
        }
        return current + [next.element, separatedBy]
      }
    }
  }
}

extension Text {

  fileprivate static func serialized(rawValue: String, backgroundColor: Color?) -> Text {
    guard let backgroundColor else { return Text(rawValue) }
    guard #available(iOS 15.0, *) else { return Text(rawValue).underline(true, color: backgroundColor) }

    var attributedString = AttributedString(rawValue)
    attributedString.backgroundColor = backgroundColor
    return .init(attributedString)
  }
}

extension String {
  fileprivate var covertWhiteSpace: String {
    replacingOccurrences(of: "<br>", with: "\n")
      .replacingOccurrences(of: "<n>", with: "\n")
      .replacingOccurrences(of: "<br/>", with: "\n")
      .replacingOccurrences(of: "<br />", with: "\n")
  }
}

extension EnvironmentValues {
  @Entry public var fontScale: CGFloat = 1
}
