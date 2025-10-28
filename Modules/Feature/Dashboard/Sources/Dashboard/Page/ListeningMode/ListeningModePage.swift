import Architecture
import ComposableArchitecture
import DesignSystem
import Domain
import Functor
import SwiftUI

// MARK: - ListeningModePage

struct ListeningModePage {

  init(store: StoreOf<ListeningModeReducer>) {
    self.store = store
  }

  @Bindable private var store: StoreOf<ListeningModeReducer>
  @State private var downloadLocale: Locale?
}

extension ListeningModePage {

  @MainActor
  private var recodingButtonDisabled: Bool {
    guard let progress = store.downloadProgress else { return false }
    return progress < 1
  }
}

// MARK: View

extension ListeningModePage: View {

  var body: some View {
    VStack {
      SelectLanguage(
        languageList: store.fetchLanguageItemList.value,
        disabled: store.isPlay,
        onChangeStart: { store.send(.set(\.start, $0)) },
        onChangeEnd: { store.send(.set(\.end, $0)) },
        onError: { store.send(.throwError($0)) }
      )
      .padding(EdgeInsets(top: 16, leading: 8, bottom: 4, trailing: 8))
      ContentList(
        viewState: store.contentViewState,
        updateAction: { store.send(.updateItem($0)) },
        errorAction: { store.send(.throwError($0)) }
      )
      .padding(8)
      Spacer()
      HStack {
        Spacer()
        Button(action: {
          store.send(store.isPlay ? .stopRecording : .playRecording)
        }) {
          let imageName = store.isPlay ? "stop.circle.fill" : "play.circle.fill"
          Image(systemName: imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 60, height: 60)
        }
        .tint(store.isPlay ? Color.accentColor : SystemColor.Label.OnBG.primary.color)
        .buttonStyle(.plain)
        .disabled(recodingButtonDisabled)

        Spacer()
      }
      .overlay(alignment: .topTrailing) {
        Button(action: { store.send(.routeToHistoryList) }) {
          Image(systemName: "clock")
            .opacity(0.8)
        }
        .buttonStyle(.plain)
        .padding(16)
      }
      .padding(8)
    }
    .background(.background)
    .onAppear { }
    .task {
      await AudioPermissionFunctor.permission()
      store.send(.getLanguageItems)
    }
    .onDisappear {
      store.send(.teardown)
    }
  }
}
