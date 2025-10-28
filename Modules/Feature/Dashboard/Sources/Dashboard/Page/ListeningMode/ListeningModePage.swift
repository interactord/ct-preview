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
    }
    .toolbar {
      ToolbarItemGroup(placement: .primaryAction) {
        Button(action: { store.send(.set(\.isAutoDetect, !store.isAutoDetect)) }) {
          Image(systemName: store.isAutoDetect ? "arrow.left.arrow.right" : "arrow.right")
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)

        Button(action: { store.send(.routeToHistoryList) }) {
          Image(systemName: "clock")
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
      }
    }
#if os(iOS)
    .navigationBarTitleDisplayMode(.inline)
#endif
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

