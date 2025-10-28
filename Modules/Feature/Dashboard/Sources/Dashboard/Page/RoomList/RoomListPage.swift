import Architecture
import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

// MARK: - RoomListPage

struct RoomListPage {

  init(store: StoreOf<RoomListReducer>) {
    self.store = store
  }

  @Bindable private var store: StoreOf<RoomListReducer>
}

extension RoomListPage: View {

  var body: some View {
    List(store.fetchRoomList.value) { item in
      RoomItem(
        item: item,
        tapAction: { store.send(.routeToRoomDetail($0)) }
      )
      .swipeActions(edge: .trailing, allowsFullSwipe: true) {
        Button(role: .destructive, action: {
          store.send(.deleteItem(item))
        }) {
          Label("삭제", systemImage: "trash")
        }
      }
    }
    .listRowInsets(.zero)
    .listStyle(.automatic)
    .scrollContentBackground(.hidden)
    .listRowSeparator(.hidden)

    .toolbar {
      ToolbarItemGroup(placement: .navigation) {
        Button(action: { store.send(.routeToBack) }) {
          Image(systemName: "arrow.backward")
        }
        .buttonStyle(.plain)
      }

      ToolbarItemGroup(placement: .primaryAction) {
        Button(action: { store.send(.deleteAllItem) }) {
          Text("전부삭제")
            .padding(.horizontal, 8)
            .foregroundStyle(Color.red)
            .fontWeight(.bold)
        }
        .buttonStyle(.plain)
      }
    }
    .background(.background)
    .task {
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
      .background(Color.clear)
      .onTapGesture {
        tapAction(item)
      }
    }
    .padding(16)
  }
}

extension Double {
  func toLocalized() -> String {
    let date = Date(timeIntervalSince1970: self)
    return DateFormatter.localizedYMDHM.string(from: date)
  }
}

extension DateFormatter {
  fileprivate static let localizedYMDHM: DateFormatter = {
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

extension EdgeInsets {
  fileprivate static var zero: EdgeInsets {
    EdgeInsets(top: .zero, leading: .zero, bottom: .zero, trailing: .zero)
  }
}
