import Foundation
import SwiftUI

// MARK: - DesignSystemRadioButton

public struct DesignSystemRadioButton<T: Equatable> {
  public init(title: String, value: Binding<T?>, target: T) {
    self.title = title
    _value = value
    self.target = target
  }

  @Binding var value: T?

  let title: String
  let target: T

  var isSelected: Bool {
    value == target
  }

}

// MARK: View

extension DesignSystemRadioButton {
  @ViewBuilder
  var image: some View {
    if isSelected {
      Image(.icBtnRadioOn)
        .resizable()
        .frame(width: 24, height: 24, alignment: .center)
    } else {
      Image(.icBtnRadio)
        .renderingMode(.template)
        .resizable()
        .frame(width: 24, height: 24, alignment: .center)
        .foregroundStyle(SystemColor.grey.color)
    }
  }

  var tintColor: Color {
    SystemColor.Tint.blue.color
  }

  var primaryColor: Color {
    SystemColor.Label.OnBG.primary.color
  }
}

// MARK: View

extension DesignSystemRadioButton: View {
  public var body: some View {
    Button(action: { value = target }, label: {
      HStack(spacing: 16) {
        image

        DesignSystemText(text: title)
          .setFontSize(fontSize: .font14)
          .setFontColor(fontColor: primaryColor)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
      .background {
        RoundedRectangle(cornerRadius: 8)
          .stroke(isSelected ? tintColor : SystemColor.grey3.color, lineWidth: 1)
      }
      .contentShape(.rect)
    })
    .buttonStyle(.plain)
  }
}
