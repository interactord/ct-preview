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
        Button(action: { store.send(.routeToListeningMode) }) {
          Text("듣기 모드")
        }
        Spacer()
      }
      Spacer()
    }
    .background(.background)
    .onAppear {
      print("AAAAA")
    }
    .onDisappear {
      print("BBBBB")
      store.send(.teardown)
    }
  }
}
