import ComposableArchitecture
import LinkNavigatorSwiftUI
import SwiftUI

// MARK: - SplashPage

struct SplashPage {

  init(store: StoreOf<SplashReducer>) {
    self.store = store
  }

  @Bindable private var store: StoreOf<SplashReducer>
}

// MARK: View

extension SplashPage: View {

  var body: some View {
    VStack {
      Spacer()
      HStack {
        Spacer()
        Text("SplashPage")
        Spacer()
      }
      Spacer()
    }
    .background(.background)
    .onAppear {
    }
  }
}
