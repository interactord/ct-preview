import Foundation
import SwiftUI

// MARK: - CustomDialog

struct CustomDialog<DialogContent: View>: ViewModifier {

  // MARK: Lifecycle

  init(
    isPresented: Binding<Bool>,
    cornerRadius: CGFloat,
    @ViewBuilder dialogContent: @escaping () -> DialogContent
  ) {
    _isPresented = isPresented
    self.cornerRadius = cornerRadius
    self.dialogContent = dialogContent()
  }

  // MARK: Internal

  @Binding var isPresented: Bool

  let cornerRadius: CGFloat
  let dialogContent: DialogContent

  func body(content: Content) -> some View {
    ZStack {
      content

      ZStack {
        if isPresented {
          Rectangle()
            .ignoresSafeArea()
            .foregroundColor(SystemColor.Overlay.Basic.default.color)
            .transition(
              .opacity
                .animation(.easeOut(duration: 0.15))
            )

          Group {
            dialogContent
              .containerRelativeFrame(.horizontal) { width, _ in
                min(width * 0.8, 500)
              }
          }
          .transition(
            .opacity
              .animation(.easeOut(duration: 0.15))
          )
        }
      }
      .animation(.easeInOut, value: isPresented)
    }
  }
}

extension View {
  public func customDialog(
    isPresented: Binding<Bool>,
    cornerRadius: CGFloat,
    @ViewBuilder dialogContent: @escaping () -> some View
  ) -> some View {
    modifier(
      CustomDialog(
        isPresented: isPresented,
        cornerRadius: cornerRadius,
        dialogContent: dialogContent
      )
    )
  }
}
