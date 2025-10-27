import Architecture
import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

struct RoomPage {

  init(store: StoreOf<RoomReducer>) {
    self.store = store
  }

  @Bindable private var store: StoreOf<RoomReducer>
}

extension RoomPage {

}

extension RoomPage: View {

  var body: some View {
    NavigationView {
      List(store.item.itemList) { item in
        RoomPage.ContentItem(item: item)
      }
      .navigationTitle("")
      .toolbar {
        ToolbarItem {
          Button(action: { store.send(.routeToBack) }) {
            Text("Back")
          }
          .buttonStyle(.plain)
        }
      }
    }
    .background(.background)
  }
}

extension RoomPage {
  struct ContentItem: View {
    let item: TranscriptionEntity.Item

    var body: some View {
      VStack {
        HStack {
          Text(item.text)
            .font(.system(size: 12, weight: .regular, design: .default))
            .transition(.opacity)
          Spacer(minLength: .zero)
        }
        .opacity(0.8)

        Spacer(minLength: 8)

        if let translation = item.translation {
          HStack {
            Text(translation.text)
              .font(.system(size: 18, weight: .bold, design: .default))
              .foregroundStyle(Color.accentColor)
            Spacer(minLength: .zero)
          }
        }
      }
    }
  }
}
