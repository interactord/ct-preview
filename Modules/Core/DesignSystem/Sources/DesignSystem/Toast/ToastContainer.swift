import SwiftUI

// MARK: - ToastContainer

public struct ToastContainer {

  public init(viewModel: ToastContainerViewModel) {
    self.viewModel = viewModel
  }

  @State private var viewModel: ToastContainerViewModel
}

// MARK: View

extension ToastContainer: View {

  public var body: some View {
    Toast(
      toastItem: viewModel.toastMessage,
      type: .default
    )
    .onTapGesture {
      viewModel.cancel()
    }
  }
}
