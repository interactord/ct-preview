import SwiftUI

// MARK: - DesignSystemDropdownButton

public struct DesignSystemDropdownButton: View {

  // MARK: Lifecycle

  public init(
    placeholder: String,
    title: String?,
    hintMessage: String? = .none,
    isError: Bool = false,
    action: @escaping () -> Void,
    isDisabled: Bool = false,
    buttonStyle: DesignSystemDropdownStyle = .defaultStyle
  ) {
    self.placeholder = placeholder
    self.title = title
    self.action = action
    self.isDisabled = isDisabled
    self.buttonStyle = buttonStyle
    self.hintMessage = hintMessage
    self.isError = isError
  }

  // MARK: Public

  public var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Button(action: action) {
        DesignSystemDropdownView(
          placeholder: placeholder,
          title: title,
          isError: isError,
          isDisabled: isDisabled,
          buttonStyle: buttonStyle
        )
      }
      .disabled(isDisabled)
      .buttonStyle(.plain)

      DesignSystemText(text: hintMessage)
        .setFontSize(fontSize: .font12)
        .setFontColor(fontColor: hintMessageColor)
    }
  }

  // MARK: Private

  private struct DesignSystemDropdownView: View {

    // MARK: Lifecycle

    init(
      placeholder: String,
      title: String?,
      isError: Bool,
      isDisabled: Bool,
      buttonStyle: DesignSystemDropdownStyle
    ) {
      self.placeholder = placeholder
      self.title = title
      self.isError = isError
      fieldType = buttonStyle.fieldType
      sizeType = buttonStyle.sizeType
      self.isDisabled = isDisabled
    }

    // MARK: Internal

    var placeholder: String
    var title: String?
    var fieldType: DesignSystemDropdownStyle.FieldType
    var sizeType: DesignSystemDropdownStyle.SizeType
    var isDisabled: Bool
    var isError: Bool

    var fontValue: Font {
      switch sizeType {
      case .s:
        .system(size: 14)
      case .m:
        .system(size: 16)
      case .l:
        .system(size: 18)
      }
    }

    var iconSize: CGFloat {
      switch sizeType {
      case .s: 12
      case .m, .l: 16
      }
    }

    var paddingValue: EdgeInsets {
      switch fieldType {
      case .fixed, .flexible:
        switch sizeType {
        case .s:
          .init(top: 8, leading: 12, bottom: 8, trailing: 12)
        case .m:
          .init(top: 13, leading: 12, bottom: 13, trailing: 12)
        case .l:
          .init(top: 16, leading: 16, bottom: 16, trailing: 16)
        }

      case .ghost:
        .init()
      }
    }

    var backgroundColor: Color {
      switch fieldType {
      case .fixed, .flexible:
        SystemColor.Background.Default.base.color
      case .ghost:
        .clear
      }
    }

    var titleColor: Color {
      guard !isDisabled else { return SystemColor.Label.OnBG.tertiary.color }
      return title == .none
        ? SystemColor.Label.OnBG.tertiary.color
        : SystemColor.Label.OnBG.primary.color
    }

    var borderColor: Color {
      guard !isDisabled else { return SystemColor.Label.OnBG.tertiary.color }
      guard !isError else { return SystemColor.Tint.red.color }
      switch fieldType {
      case .fixed, .flexible:
        return SystemColor.grey3.color
      case .ghost:
        return .clear
      }
    }

    @ViewBuilder
    var commonContent: some View {
      switch fieldType {
      case .flexible, .ghost:
        HStack {
          Text(title ?? placeholder)
            .lineLimit(1)
            .truncationMode(.tail)
            .font(fontValue)
            .foregroundColor(titleColor)

          Image(.icDropdown)
            .renderingMode(.template)
            .resizable()
            .frame(width: iconSize, height: iconSize)
            .foregroundColor(SystemColor.Label.OnBG.Secondary.color)
            .aspectRatio(contentMode: .fit)
        }

      case .fixed:
        HStack {
          Text(title ?? placeholder)
            .lineLimit(1)
            .truncationMode(.tail)
            .font(fontValue)
            .foregroundColor(titleColor)

          Spacer()

          Image(.icDropdown)
            .resizable()
            .frame(width: iconSize, height: iconSize)
            .foregroundColor(SystemColor.Label.OnBG.Secondary.color)
            .aspectRatio(contentMode: .fit)
        }
      }
    }

    @ViewBuilder
    var content: some View {
      switch fieldType {
      case .fixed, .flexible:
        commonContent
          .padding(paddingValue)
          .background(backgroundColor)
          .overlay(
            RoundedRectangle(cornerRadius: 4)
              .stroke(borderColor, lineWidth: 1)
          )

      case .ghost:
        commonContent
      }
    }

    var body: some View {
      content
    }
  }

  private var placeholder: String
  private var title: String?
  private var hintMessage: String?
  private var action: () -> Void
  private var buttonStyle: DesignSystemDropdownStyle
  private var isDisabled: Bool

  private var isError: Bool

  private var hintMessageColor: Color {
    isError ? SystemColor.Tint.red.color : SystemColor.Label.OnBG.Secondary.color
  }

}

extension DesignSystemDropdownButton {
  public func mutate(buttonStyle: DesignSystemDropdownStyle) -> Self {
    .init(
      placeholder: placeholder,
      title: title,
      isError: isError,
      action: action,
      isDisabled: isDisabled,
      buttonStyle: buttonStyle
    )
  }

  public func setSize(sizeType: DesignSystemDropdownStyle.SizeType) -> Self {
    let style = DesignSystemDropdownStyle(
      fieldType: buttonStyle.fieldType,
      sizeType: sizeType
    )

    return mutate(buttonStyle: style)
  }

  public func setFieldType(fieldType: DesignSystemDropdownStyle.FieldType) -> Self {
    let style = DesignSystemDropdownStyle(
      fieldType: fieldType,
      sizeType: buttonStyle.sizeType
    )

    return mutate(buttonStyle: style)
  }
}

// MARK: - DesignSystemDropdownStyle

public struct DesignSystemDropdownStyle {
  public init(fieldType: FieldType, sizeType: SizeType) {
    self.fieldType = fieldType
    self.sizeType = sizeType
  }

  fileprivate var fieldType: FieldType
  fileprivate var sizeType: SizeType
}

extension DesignSystemDropdownStyle {
  public enum FieldType {
    case fixed
    case flexible
    case ghost
  }

  public enum SizeType {
    case s
    case m
    case l
  }
}

extension DesignSystemDropdownStyle {
  public static var defaultStyle: Self {
    .init(
      fieldType: .fixed,
      sizeType: .m
    )
  }
}
