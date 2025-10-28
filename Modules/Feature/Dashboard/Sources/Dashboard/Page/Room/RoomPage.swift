import Architecture
import ComposableArchitecture
import DesignSystem
import Domain
import SwiftUI

// MARK: - RoomPage

struct RoomPage {

  init(store: StoreOf<RoomReducer>) {
    self.store = store
  }

  @State var frameWidth = CGFloat.zero
  @State var frameHeight = CGFloat.zero

  @Bindable private var store: StoreOf<RoomReducer>
}

extension RoomPage {
  @MainActor
  var isLoading: Bool {
    store.item.summery == .none
  }
}

extension RoomPage: View {

  var body: some View {
    VStack {
      GeometryReader { proxy in
        List(store.item.itemList) { item in
          RoomPage.ContentItem(item: item)
        }
        .scrollContentBackground(.hidden)
        .listRowBackground(Color.clear)
        .listStyle(.plain)
        .padding(16)
        .task {
          frameWidth = proxy.size.width
          frameHeight = proxy.size.height
        }
      }
    }
    .navigationTitle("")
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
        if store.item.summery != .none {
          Button(action: { store.send(.routeToSummerySheet) }) {
            Text("요약 내용 보기")
              .fontWeight(.bold)
              .padding(.horizontal, 16)
          }
          .tint(Color.accentColor)
          .buttonStyle(.plain)
        } else {
          ProgressView()
            .progressViewStyle(.circular)
            .controlSize(.small)
            .scaleEffect(0.8)
        }
      }
      .sharedBackgroundVisibility(.hidden)
    }
    #if os(macOS)
    .sheet(unwrapping: $store.route, case: \.summerySheet) { _ in
      VStack {
        HStack {
          Button(action: { store.send(.routeClear) }) {
            Image(systemName: "xmark")
              .fontWeight(.bold)
          }
          .tint(Color.accentColor)
          .buttonStyle(.plain)

          Spacer()

          ShareLink(item: store.item.summery ?? "") {
            Label("요약 공유", systemImage: "square.and.arrow.up")
          }
        }
        .padding(.bottom, 8)
        Divider()

        ScrollView {
          HStack {
            Text(store.item.summery ?? "")
          }
        }
      }
      .background(.background)
      .padding(16)
      .frame(width: frameWidth * 0.8, height: frameHeight * 0.8)
    }
    #else
    .sheet(unwrapping: $store.route, case: \.summerySheet) { _ in
        NavigationView {
          VStack {
            ScrollView {
              HStack {
                Text(store.item.summery ?? "")
              }
            }
            .scrollContentBackground(.hidden)
            .padding(16)
          }
          .background(.background)
          .toolbar {
            ToolbarItemGroup(placement: .navigation) {
              Button(action: { store.send(.routeClear) }) {
                Image(systemName: "xmark")
                  .fontWeight(.bold)
              }
              .tint(Color.accentColor)
              .buttonStyle(.plain)
            }

            ToolbarItem(placement: .primaryAction) {
              ShareLink(item: store.item.summery ?? "") {
                Label("요약 공유", systemImage: "square.and.arrow.up")
              }
            }
          }
        }
      }
    #endif
      .background(.background)
      .task {
        store.send(.getSummery)
      }
      .onDisappear {
        store.send(.teardown)
      }
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
              .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: .zero)
          }
        }
      }
    }
  }
}
