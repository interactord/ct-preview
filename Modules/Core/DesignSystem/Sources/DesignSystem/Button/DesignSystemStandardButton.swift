import SwiftUI

// MARK: - DesignSystemPreview

struct DesignSystemPreview: View {
  var body: some View {
    VStack {
      DesignSystemStandardButton(
        action: {
//          print("onTapped")
        },
        text: "StandardButton"
      )
      .setSize(sizeType: .l)

      DesignSystemStandardButton(
        action: {
//          print("onTapped")
        },
        text: "StandardButton"
      )
      .setSize(sizeType: .s)
    }
  }
}

extension DesignSystemStandardButton {
  public func mutate(buttonStyle: DesignSystemButtonStandardStyle) -> Self {
    .init(action: action, text: text, isDisabled: isDisabled, buttonStyle: buttonStyle)
  }

  public func changedAttribute(buttonStyle: DesignSystemButtonStandardStyle) -> Self {
    let style = DesignSystemButtonStandardStyle(
      contentType: buttonStyle.contentType,
      layoutType: buttonStyle.layoutType,
      sizeType: buttonStyle.sizeType,
      kindType: buttonStyle.kindType,
      multilineType: buttonStyle.multilineType,
      isMaxWidth: buttonStyle.isMaxWidth
    )

    return mutate(buttonStyle: style)
  }

  public func setSize(sizeType: DesignSystemButtonStandardStyle.SizeType) -> Self {
    let style = DesignSystemButtonStandardStyle(
      contentType: buttonStyle.contentType,
      layoutType: buttonStyle.layoutType,
      sizeType: sizeType,
      kindType: buttonStyle.kindType,
      multilineType: buttonStyle.multilineType,
      isMaxWidth: buttonStyle.isMaxWidth
    )

    return mutate(buttonStyle: style)
  }

  public func setLayout(layoutType: DesignSystemButtonStandardStyle.LayoutType) -> Self {
    let style = DesignSystemButtonStandardStyle(
      contentType: buttonStyle.contentType,
      layoutType: layoutType,
      sizeType: buttonStyle.sizeType,
      kindType: buttonStyle.kindType,
      multilineType: buttonStyle.multilineType,
      isMaxWidth: buttonStyle.isMaxWidth
    )

    return mutate(buttonStyle: style)
  }

  public func setContentType(contentType: DesignSystemButtonStandardStyle.ContentType) -> Self {
    let style = DesignSystemButtonStandardStyle(
      contentType: contentType,
      layoutType: buttonStyle.layoutType,
      sizeType: buttonStyle.sizeType,
      kindType: buttonStyle.kindType,
      multilineType: buttonStyle.multilineType,
      isMaxWidth: buttonStyle.isMaxWidth
    )

    return mutate(buttonStyle: style)
  }

  public func setKindType(kindType: DesignSystemButtonStandardStyle.KindType) -> Self {
    let style = DesignSystemButtonStandardStyle(
      contentType: buttonStyle.contentType,
      layoutType: buttonStyle.layoutType,
      sizeType: buttonStyle.sizeType,
      kindType: kindType,
      multilineType: buttonStyle.multilineType,
      isMaxWidth: buttonStyle.isMaxWidth
    )

    return mutate(buttonStyle: style)
  }

  public func setMultilineType(multilineType: DesignSystemButtonStandardStyle.MultilineType) -> Self {
    let style = DesignSystemButtonStandardStyle(
      contentType: buttonStyle.contentType,
      layoutType: buttonStyle.layoutType,
      sizeType: buttonStyle.sizeType,
      kindType: buttonStyle.kindType,
      multilineType: multilineType,
      isMaxWidth: buttonStyle.isMaxWidth
    )

    return mutate(buttonStyle: style)
  }

  public func setMaxWidth() -> Self {
    let style = DesignSystemButtonStandardStyle(
      contentType: buttonStyle.contentType,
      layoutType: buttonStyle.layoutType,
      sizeType: buttonStyle.sizeType,
      kindType: buttonStyle.kindType,
      multilineType: buttonStyle.multilineType,
      isMaxWidth: true
    )

    return mutate(buttonStyle: style)
  }
}

extension DesignSystemButtonStandardStyle {
  mutating func mutate<Value: Equatable>(
    keyPath: WritableKeyPath<DesignSystemButtonStandardStyle, Value>,
    to value: Value
  ) -> Self {
    self[keyPath: keyPath] = value
    return self
  }
}

// MARK: - DesignSystemStandardButton_Previews

struct DesignSystemStandardButton_Previews: PreviewProvider {
  static var previews: some View {
    DesignSystemStandardButton(
      action: { },
      text: "Standard Button",
      isDisabled: false
    )
    .setLayout(layoutType: .ghost)
    .setSize(sizeType: .l)
    .setKindType(kindType: .primary)
    .setContentType(contentType: .iconWithText(Image(systemName: "folder"), isSpacer: false))
    .setMaxWidth()
  }
}

// MARK: - DesignSystemStandardButton

public struct DesignSystemStandardButton: View {

  // MARK: Lifecycle

  public init(
    action: @escaping () -> Void,
    text: String,
    isDisabled: Bool = false,
    buttonStyle: DesignSystemButtonStandardStyle = .defaultStyle
  ) {
    self.action = action
    self.text = text
    self.isDisabled = isDisabled
    self.buttonStyle = buttonStyle
  }

  // MARK: Public

  public var body: some View {
    Button(action: action) {
      StandardButtonView(
        text: text,
        contentType: buttonStyle.contentType,
        sizeType: buttonStyle.sizeType,
        kindType: buttonStyle.kindType,
        layoutType: buttonStyle.layoutType,
        multilineType: buttonStyle.multilineType,
        isMaxWidth: buttonStyle.isMaxWidth,
        isDisabled: isDisabled
      )
      .contentShape(.rect)
    }
    .disabled(isDisabled)
    .buttonStyle(.plain)
  }

  // MARK: Internal

  @State var buttonStyle: DesignSystemButtonStandardStyle

  var text: String
  var image: Image?
  var action: () -> Void
  var isDisabled: Bool

  // MARK: Private

  private struct StandardButtonView: View {

    // MARK: Lifecycle

    init(
      text: String,
      contentType: DesignSystemButtonStandardStyle.ContentType,
      sizeType: DesignSystemButtonStandardStyle.SizeType,
      kindType: DesignSystemButtonStandardStyle.KindType,
      layoutType: DesignSystemButtonStandardStyle.LayoutType,
      multilineType: DesignSystemButtonStandardStyle.MultilineType,
      isMaxWidth: Bool,
      isDisabled: Bool
    ) {
      self.text = text
      self.contentType = contentType
      self.sizeType = sizeType
      self.kindType = kindType
      self.layoutType = layoutType
      self.multilineType = multilineType
      self.isMaxWidth = isMaxWidth
      self.isDisabled = isDisabled
    }

    // MARK: Public

    public var body: some View {
      finalContent
    }

    // MARK: Internal

    var text: String
    var contentType: DesignSystemButtonStandardStyle.ContentType
    var sizeType: DesignSystemButtonStandardStyle.SizeType
    var kindType: DesignSystemButtonStandardStyle.KindType
    var layoutType: DesignSystemButtonStandardStyle.LayoutType
    var multilineType: DesignSystemButtonStandardStyle.MultilineType
    var isMaxWidth: Bool
    var isDisabled: Bool

    var fontValue: Font {
      switch sizeType {
      case .xs:
        switch contentType {
        case .floatingIcon:
          .system(size: 16).bold()
        default:
          .system(size: 14).bold()
        }

      case .s:
        .system(size: 16).bold()

      case .m:
        .system(size: 16).bold()

      case .l:
        switch contentType {
        case .floatingIcon:
          .system(size: 24).bold()
        default:
          .system(size: 16).bold()
        }
      }
    }

    var iconSizeWithText: CGFloat {
      switch sizeType {
      case .xs: 12
      default: 16
      }
    }

    var iconSizeFloating: CGFloat {
      switch sizeType {
      case .l: 24
      default: 16
      }
    }

    var fontColor: Color {
      switch kindType {
      case .primary:
        switch layoutType {
        case .fill:
          SystemColor.white.color
        case .outline, .ghost:
          SystemColor.Tint.blue.color
        }

      case .secondary:
        SystemColor.Label.OnBG.primary.color
      }
    }

    var paddingValue: EdgeInsets {
      switch contentType {
      case .text:
        switch sizeType {
        case .xs:
          .init(top: 5, leading: 12, bottom: 5, trailing: 12)
        case .s:
          .init(top: 9, leading: 16, bottom: 9, trailing: 16)
        case .m:
          .init(top: 13, leading: 24, bottom: 13, trailing: 24)
        case .l:
          .init(top: 17, leading: 24, bottom: 17, trailing: 24)
        }

      case .textWithIcon:
        switch sizeType {
        case .xs:
          .init(top: 5, leading: 11, bottom: 5, trailing: 12)
        case .s:
          .init(top: 9, leading: 14, bottom: 9, trailing: 16)
        case .m:
          .init(top: 13, leading: 20, bottom: 13, trailing: 20)
        case .l:
          .init(top: 17, leading: 20, bottom: 17, trailing: 20)
        }

      case .iconWithText:
        switch sizeType {
        case .xs:
          .init(top: 5, leading: 12, bottom: 5, trailing: 11)
        case .s:
          .init(top: 9, leading: 16, bottom: 9, trailing: 14)
        case .m:
          .init(top: 13, leading: 24, bottom: 13, trailing: 20)
        case .l:
          .init(top: 17, leading: 24, bottom: 17, trailing: 20)
        }

      case .floatingIcon:
        switch sizeType {
        case .xs:
          .init(top: 7, leading: 7, bottom: 7, trailing: 7)
        case .s:
          .init(top: 8, leading: 8, bottom: 8, trailing: 8)
        case .m:
          .init(top: 12, leading: 12, bottom: 12, trailing: 12)
        case .l:
          .init(top: 16, leading: 16, bottom: 16, trailing: 16)
        }
      }
    }

    var backgroundColor: Color? {
      switch kindType {
      case .primary:
        switch layoutType {
        case .fill:
          SystemColor.Tint.blue.color
        case .outline, .ghost:
          .clear
        }

      case .secondary:
        switch layoutType {
        case .fill:
          SystemColor.Overlay.Thin.default.color
        case .outline, .ghost:
          .clear
        }
      }
    }

    var borderColor: Color {
      switch kindType {
      case .primary:
        switch layoutType {
        case .fill, .ghost:
          SystemColor.Tint.blue.color.opacity(0)
        case .outline:
          SystemColor.Tint.blue.color
        }

      case .secondary:
        switch layoutType {
        case .fill, .ghost:
          SystemColor.Label.OnBG.Secondary.color.opacity(0)
        case .outline:
          SystemColor.grey3.color
        }
      }
    }

    @ViewBuilder
    var content: some View {
      switch contentType {
      case .text:
        Text(text)
          .aligned(multilineType: multilineType)

      case .textWithIcon(let image, let isSpacer):
        switch isSpacer {
        case true:
          HStack {
            Text(text)
              .aligned(multilineType: multilineType)
            Spacer()
            image?.resizable()
              .renderingMode(.template)
              .aspectRatio(contentMode: .fit)
              .frame(width: iconSizeWithText, height: iconSizeWithText)
          }

        case false:
          HStack {
            Text(text)
              .aligned(multilineType: multilineType)
            image?.resizable()
              .renderingMode(.template)
              .aspectRatio(contentMode: .fit)
              .frame(width: iconSizeWithText, height: iconSizeWithText)
          }
        }

      case .iconWithText(let image, let isSpacer):
        switch isSpacer {
        case true:
          HStack {
            image?.resizable()
              .renderingMode(.template)
              .aspectRatio(contentMode: .fit)
              .frame(width: iconSizeWithText, height: iconSizeWithText)
            Spacer()
            Text(text)
              .aligned(multilineType: multilineType)
          }

        case false:
          HStack {
            image?.resizable()
              .renderingMode(.template)
              .aspectRatio(contentMode: .fit)
              .frame(width: iconSizeWithText, height: iconSizeWithText)
            Text(text)
              .aligned(multilineType: multilineType)
          }
        }

      case .floatingIcon(let image):
        image?.resizable()
          .renderingMode(.template)
          .aspectRatio(contentMode: .fit)
          .frame(width: iconSizeFloating, height: iconSizeFloating)
      }
    }

    @ViewBuilder
    var commonContent: some View {
      content
        .foregroundStyle(fontColor)
        .font(fontValue)
        .frame(minWidth: isMaxWidth ? 0 : nil, maxWidth: isMaxWidth ? .infinity : nil, alignment: .center)
        .padding(paddingValue)
    }

    @ViewBuilder
    var finalContent: some View {
      switch layoutType {
      case .fill:
        commonContent
          .background(backgroundColor)
          .clipShape(RoundedRectangle(cornerRadius: 6))
          .opacity(!isDisabled ? 1 : 0.4)

      case .outline:
        commonContent
          .background(
            RoundedRectangle(cornerRadius: 6)
              .stroke(borderColor, lineWidth: 1)
          )
          .opacity(!isDisabled ? 1 : 0.4)
          .padding(.horizontal, 1)

      case .ghost:
        commonContent
          .background(backgroundColor)
          .opacity(!isDisabled ? 1 : 0.4)
      }
    }
  }
}

// MARK: - DesignSystemButtonStandardStyle

public struct DesignSystemButtonStandardStyle {

  // MARK: Lifecycle

  public init(
    contentType: ContentType,
    layoutType: LayoutType,
    sizeType: SizeType,
    kindType: KindType,
    multilineType: MultilineType,
    isMaxWidth: Bool
  ) {
    self.contentType = contentType
    self.layoutType = layoutType
    self.sizeType = sizeType
    self.kindType = kindType
    self.multilineType = multilineType
    self.isMaxWidth = isMaxWidth
  }

  // MARK: Fileprivate

  fileprivate var contentType: ContentType
  fileprivate var layoutType: LayoutType
  fileprivate var sizeType: SizeType
  fileprivate var kindType: KindType
  fileprivate var isMaxWidth: Bool
  fileprivate var multilineType: MultilineType
}

// MARK: Equatable

extension DesignSystemButtonStandardStyle: Equatable {
  public enum ContentType: Equatable {
    case text
    case iconWithText(Image?, isSpacer: Bool = false)
    case textWithIcon(Image?, isSpacer: Bool = false)
    case floatingIcon(Image?)
  }

  public enum LayoutType: Equatable {
    case fill
    case outline
    case ghost
  }

  public enum SizeType: Equatable {
    case xs
    case s
    case m
    case l
  }

  public enum KindType: Equatable {
    case primary
    case secondary
  }

  public enum MultilineType: Equatable {
    case disable
    case enable(TextAlignment)
  }
}

extension DesignSystemButtonStandardStyle {
  public static var defaultStyle: Self {
    .init(
      contentType: .text,
      layoutType: .fill,
      sizeType: .m,
      kindType: .primary,
      multilineType: .enable(.center),
      isMaxWidth: false
    )
  }
}

extension Text {
  @ViewBuilder
  fileprivate func aligned(multilineType: DesignSystemButtonStandardStyle.MultilineType) -> some View {
    switch multilineType {
    case .disable:
      lineLimit(1)
        .fixedSize(horizontal: false, vertical: true)

    case .enable(let textAlignment):
      multilineTextAlignment(textAlignment)
    }
  }
}
