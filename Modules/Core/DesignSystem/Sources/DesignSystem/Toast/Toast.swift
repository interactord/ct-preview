import SwiftUI

// MARK: - Const

private enum Const {
  static let contentPadding: CGFloat = 16
  static let containerPadding: CGFloat = 16
}

// MARK: - Toast

public struct Toast {
  public init(toastItem: ToastItem?, type: ToastType) {
    self.toastItem = toastItem
    self.type = type
  }

  let toastItem: ToastItem?

  private let type: ToastType
}

// MARK: Toast.ToastType

extension Toast {
  public enum ToastType: Equatable {
    case `default`
    case error
  }
}

extension Toast {
  var backgroundColor: Color {
    switch type {
    case .error:
      SystemColor.Tint.red.color
    case .default:
      SystemColor.Overlay.Thick.default.color
    }
  }
}

// MARK: View

extension Toast: View {
  public var body: some View {
    VStack {
      Spacer()

      if let toastItem {
        HStack {
          if let accessory = toastItem.accessory {
            switch accessory {
            case .image(let image):
              image
                .resizable()
                .frame(width: 20, height: 20)
            }
          }

          DesignSystemText(text: toastItem.message)
            .setFontColor(fontColor: SystemColor.white.color)
            .multilineTextAlignment(.leading)
        }
        .padding(Const.contentPadding)
        .containerRelativeFrame(.horizontal, alignment: .leading) { width, _ in
          width / 3
        }
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .padding(.horizontal, Const.containerPadding)
        .id(toastItem.id)
        .transition(.opacity)
      }
    }
    .padding(.bottom, 50)
    .padding(.trailing, 50)
    .animation(.interactiveSpring(), value: toastItem)
  }
}
