import Architecture
import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

struct RoomListPage {

  init(store: StoreOf<RoomListReducer>) {
    self.store = store
  }

  @Bindable private var store: StoreOf<RoomListReducer>
}

extension RoomListPage {

}

extension RoomListPage: View {

  var body: some View {
    List(store.fetchRoomList.value) { item in
      RoomItem(
        item: item,
        tapAction: { store.send(.routeToRoomDetail($0)) })
    }
    .scrollContentBackground(.hidden)
    .toolbar {
      ToolbarItemGroup(placement: .navigation) {
        Button(action: { store.send(.routeToBack) }) {
          Image(systemName: "arrow.backward")
            .padding(.horizontal, 16)
        }
        .buttonStyle(.plain)
      }
      .sharedBackgroundVisibility(.hidden)

      ToolbarItemGroup(placement: .primaryAction) {
        Button(action: { store.send(.deleteAllItem) }) {
          Text("전부삭제")
            .foregroundStyle(Color.red)
            .fontWeight(.bold)
            .padding(.horizontal, 16)
        }
        .buttonStyle(.plain)
      }
      .sharedBackgroundVisibility(.hidden)
    }
    .background(.background)
    .onAppear {
      store.send(.getRoomList)
    }
    .onDisappear {
      store.send(.teardown)
    }
  }
}


extension RoomListPage {
  struct RoomItem {
    let item: RoomInformation
    let tapAction: (RoomInformation) -> Void
  }
}

extension RoomListPage.RoomItem: View {
  var body: some View {
    ZStack {
      VStack(spacing: 8) {
        HStack {
          Text(item.title)
            .font(Font.system(size: 18, weight: .bold, design: .default))
            .foregroundStyle(Color.accentColor)
          Spacer(minLength: .zero)
        }
        HStack {
          Text(item.createAt.toLocalized())
            .font(.system(size: 12, weight: .regular, design: .default))
            .opacity(0.7)
          Spacer(minLength: .zero)
        }
      }
      .background(.background)
      .onTapGesture {
        tapAction(item)
      }
    }
    .background(SystemColor.Background.Grouped.elevated.color)
    .padding(16)
  }
}


extension Double {
  func toLocalized() -> String {
    let date = Date(timeIntervalSince1970: self)
    return DateFormatter.localizedYMDHM.string(from: date)
  }
}

private extension DateFormatter {
  static let localizedYMDHM: DateFormatter = {
    let formatter = DateFormatter()
    // Follow user's current settings (locale, calendar, timeZone)
    formatter.locale = .current
    formatter.calendar = .current
    formatter.timeZone = .current
    // Use system-preferred styles that include year/month/day and hour/minute
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
  }()
}
