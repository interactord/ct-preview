import Foundation
import SwiftUI

// MARK: - DesignSystemTextField

public struct DesignSystemTextField: View {

  // MARK: Lifecycle

  public init(
    fieldStyle: DesignSystemTextFieldStyle = .defaultStyle,
    placeholder: String?,
    bindingText: Binding<String>,
    isShowErrorMessage: Bool = true,
    errorMessage: String
  ) {
    self.fieldStyle = fieldStyle
    self.placeholder = placeholder
    self.bindingText = bindingText
    self.isShowErrorMessage = isShowErrorMessage
    self.errorMessage = errorMessage
  }

  // MARK: Public

  public var body: some View {
    TextFieldView(
      bindingText: bindingText,
      fieldStyle: fieldStyle,
      placeholder: placeholder,
      isShowErrorMessage: isShowErrorMessage,
      errorMessage: errorMessage
    )
  }

  // MARK: Internal

  let fieldStyle: DesignSystemTextFieldStyle
  let bindingText: Binding<String>
  let placeholder: String?
  let isShowErrorMessage: Bool
  let errorMessage: String

  // MARK: Private

  private struct TextFieldView: View {

    @Binding var bindingText: String
    let fieldStyle: DesignSystemTextFieldStyle
    let placeholder: String?
    let isShowErrorMessage: Bool
    let errorMessage: String

    @State var showSecuredText = false
    @FocusState var isFocusing: Bool

//    var secureToggleImage: Image? {
//      showSecuredText
//        ? Asset.icEyeOpen.swiftUIImage
//        : Asset.icEyeClose.swiftUIImage
//    }

    var paddingValue: EdgeInsets {
      switch fieldStyle.sizeType {
      case .customPadding(let inset):
        inset
      case .s:
        .init(top: 8, leading: 12, bottom: 8, trailing: 12)
      case .m:
        .init(top: 13, leading: 12, bottom: 13, trailing: 12)
      case .l:
        .init(top: 16, leading: 16, bottom: 16, trailing: 16)
      }
    }

    var strokeColor: Color {
      if errorMessage.isEmpty, !isFocusing {
        SystemColor.grey3.color
      } else if errorMessage.isEmpty, isFocusing {
        SystemColor.Tint.blue.color
      } else if !errorMessage.isEmpty {
        SystemColor.Tint.red.color
      } else {
        SystemColor.grey3.color
      }
    }

    var body: some View {
      switch fieldStyle.maxTextLength == .none {
      case true:
        VStack {
          inputField()
            .textFieldStyle(.plain)
            .font(.system(size: 16))
            .padding(paddingValue)
            .background(RoundedRectangle(cornerRadius: 4).stroke(strokeColor, lineWidth: 1))
          if !errorMessage.isEmpty, isShowErrorMessage {
            HStack {
              DesignSystemText(text: errorMessage)
                .setFontSize(fontSize: .font12)
                .setFontColor(fontColor: SystemColor.Tint.red.color)
              Spacer()
            }
            .multilineTextAlignment(.leading)
          }
        }
        .fixedSize(horizontal: false, vertical: true)

      case false:
        VStack {
          inputField()
            .textFieldStyle(.plain)
            .padding(paddingValue)
            .background(RoundedRectangle(cornerRadius: 4).stroke(strokeColor, lineWidth: 1))
          HStack {
            if !errorMessage.isEmpty, isShowErrorMessage, isFocusing {
              HStack {
                DesignSystemText(text: errorMessage)
                  .setFontSize(fontSize: .font12)
                  .setFontColor(fontColor: SystemColor.Tint.red.color)
                Spacer()
              }
              .multilineTextAlignment(.leading)
            }
            Spacer()
            DesignSystemText(
              text: bindingText
                .filter { !$0.isWhitespace && !$0.isNewline } + "/" + "\(fieldStyle.maxTextLength ?? 0)"
            )
            .setFontSize(fontSize: .font12)
            .setFontColor(fontColor: SystemColor.Label.OnBG.Secondary.color)
          }
        }
        .fixedSize(horizontal: false, vertical: true)
      }
    }

    @ViewBuilder
    func inputField() -> some View {
      switch fieldStyle.fieldType {
      case .textOnly:
        TextField(placeholder ?? "", text: $bindingText)
          .focused($isFocusing)

      case .iconLeft(let image):
        HStack {
          image?
            .resizable()
            .renderingMode(.template)
            .frame(width: 16, height: 16)
          TextField(placeholder ?? "", text: $bindingText)
            .focused($isFocusing)
        }

      case .prefix(let prefixString):
        HStack {
          Text(prefixString)
            .foregroundColor(SystemColor.Label.OnBG.Secondary.color)
          TextField(placeholder ?? "", text: $bindingText)
            .focused($isFocusing)
        }

      case .iconRight(let image):
        HStack {
          TextField(placeholder ?? "", text: $bindingText)
            .focused($isFocusing)
          image
        }

      case .iconLeftWithSecuredButton(let image):
        if showSecuredText {
          HStack {
            image
            TextField(placeholder ?? "", text: $bindingText)
              .focused($isFocusing)
//            secureToggleImage
//              .onTapGesture {
//                showSecuredText.toggle()
//              }
          }
        } else {
          HStack {
            image
            SecureField(placeholder ?? "", text: $bindingText)
              .focused($isFocusing)
//            secureToggleImage
//              .onTapGesture {
//                showSecuredText.toggle()
//              }
          }
        }

      case .securedTextOnly:
        if showSecuredText {
          HStack {
            TextField(placeholder ?? "", text: $bindingText)
              .focused($isFocusing)
//            secureToggleImage
//              .onTapGesture {
//                showSecuredText.toggle()
//              }
          }
        } else {
          HStack {
            SecureField(placeholder ?? "", text: $bindingText)
              .focused($isFocusing)
//            secureToggleImage
//              .onTapGesture {
//                showSecuredText.toggle()
//              }
          }
        }

      case .securedIconLeft(let image):
        if showSecuredText {
          HStack {
            image?
              .resizable()
              .renderingMode(.template)
              .foregroundStyle(SystemColor.Label.OnBG.tertiary.color)
              .frame(width: 16, height: 16)

            TextField(placeholder ?? "", text: $bindingText)
              .focused($isFocusing)
//            secureToggleImage
//              .onTapGesture {
//                showSecuredText.toggle()
//              }
          }
        } else {
          HStack {
            image?
              .resizable()
              .renderingMode(.template)
              .foregroundStyle(SystemColor.Label.OnBG.tertiary.color)
              .frame(width: 16, height: 16)

            SecureField(placeholder ?? "", text: $bindingText)
              .focused($isFocusing)
//            secureToggleImage
//              .onTapGesture {
//                showSecuredText.toggle()
//              }
          }
        }

      case .securedIconRight(let image):
        if showSecuredText {
          HStack {
            TextField(placeholder ?? "", text: $bindingText)
              .focused($isFocusing)
            image
//            secureToggleImage
//              .onTapGesture {
//                showSecuredText.toggle()
//              }
          }
        } else {
          HStack {
            SecureField(placeholder ?? "", text: $bindingText)
              .focused($isFocusing)
            image
//            secureToggleImage
//              .onTapGesture {
//                showSecuredText.toggle()
//              }
          }
        }
      }
    }
  }
}

extension DesignSystemTextField {
  public func mutate(fieldStyle: DesignSystemTextFieldStyle) -> Self {
    .init(
      fieldStyle: fieldStyle,
      placeholder: placeholder,
      bindingText: bindingText,
      isShowErrorMessage: isShowErrorMessage,
      errorMessage: errorMessage
    )
  }

  public func setFieldType(fieldType: DesignSystemTextFieldStyle.FieldType) -> Self {
    let style = DesignSystemTextFieldStyle(
      fieldType: fieldType,
      size: fieldStyle.sizeType,
      maxTextLength: fieldStyle.maxTextLength
    )

    return mutate(fieldStyle: style)
  }

  public func setFieldSize(fieldSize: DesignSystemTextFieldStyle.SizeType) -> Self {
    let style = DesignSystemTextFieldStyle(
      fieldType: fieldStyle.fieldType,
      size: fieldSize,
      maxTextLength: fieldStyle.maxTextLength
    )

    return mutate(fieldStyle: style)
  }

  public func setMaxLength(maxLength: Int) -> some View {
    ModifiedContent(
      content: self,
      modifier: MaxLengthModifier(text: bindingText, maxLength: maxLength)
    )
  }
}

// MARK: - DesignSystemTextFieldStyle

public struct DesignSystemTextFieldStyle {
  public init(fieldType: FieldType, size: SizeType, maxTextLength: Int?) {
    self.fieldType = fieldType
    sizeType = size
    self.maxTextLength = maxTextLength
  }

  let fieldType: FieldType
  let sizeType: SizeType
  let maxTextLength: Int?
}

extension DesignSystemTextFieldStyle {
  public static var defaultStyle: Self {
    .init(
      fieldType: .textOnly,
      size: .m,
      maxTextLength: .none
    )
  }

  public static var numericStyle: Self {
    .init(
      fieldType: .textOnly,
      size: .m,
      maxTextLength: .none
    )
  }
}

extension DesignSystemTextFieldStyle {
  public enum FieldType {
    case textOnly
    case iconLeft(Image?)
    case prefix(String)
    case iconRight(Image?)
    case iconLeftWithSecuredButton(Image?)
    case securedTextOnly
    case securedIconLeft(Image?)
    case securedIconRight(Image?)
  }

  public enum SizeType {
    case customPadding(EdgeInsets)
    case s
    case m
    case l
  }
}

// MARK: - MaxLengthModifier

private struct MaxLengthModifier: ViewModifier {
  @Binding var text: String

  let maxLength: Int

  func body(content: Content) -> some View {
    content
      .onChange(of: text) { oldValue, newValue in
        if newValue.count > maxLength {
          text = oldValue
        }
      }
  }
}
