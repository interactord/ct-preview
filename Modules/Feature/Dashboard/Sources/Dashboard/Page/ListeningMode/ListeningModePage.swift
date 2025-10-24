import ComposableArchitecture
import Domain
import LinkNavigatorSwiftUI
import SwiftUI
import DesignSystem
import Functor
import Architecture

// MARK: - SplashPage

struct ListeningModePage {

  init(store: StoreOf<ListeningModeReducer>) {
    self.store = store
  }
  @Bindable private var store: StoreOf<ListeningModeReducer>
  @State private var downloadLocale: Locale?
}

extension ListeningModePage {
}

// MARK: View

extension ListeningModePage: View {

  var body: some View {
    VStack {
      SelectLanguage(
        languageList: store.fetchLanguageItemList.value,
        disabled: store.isPlay,
        onChangeStart: { store.send(.set(\.start, $0)) },
        onChangeEnd: { store.send(.set(\.end, $0)) })
      .padding(EdgeInsets(top: 16, leading: 8, bottom: 4, trailing: 8))
      ContentList(
        viewState: store.contentViewState,
        updateAction: { store.send(.updateItem($0)) })
      .padding(8)
      Spacer()
      HStack {
        Spacer()
        Button(action: {
          store.send(store.isPlay ? .stopRecording: .playRecording)
        }) {
          let imageName = store.isPlay ? "stop.circle.fill" : "play.circle.fill"
          Image(systemName: imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 60, height: 60)
        }
        .tint(store.isPlay ?  Color.accentColor : SystemColor.Label.OnBG.primary.color)
        .buttonStyle(.plain)

        Spacer()
      }
      .padding(8)
    }
    .background(.background)
//    .translationTask(configuration) { session in
//      Task {
//        do {
//          try await session.prepareTranslation()
//        } catch {
//          print("[ERRRRRRRRR] \(error)")
//        }
//      }
//    }
//    .onChange(of: store.languageInfo, { old, new in
//      guard old != new else { return }
//      guard let start = new.start, let end = new.end else { return }
//      print("AAAA OLD ", old)
//      print("AAAA NEW ", new)
//      Task {
//        try? await Task.sleep(for: .seconds(1))
//        configuration = .init(
//          source: start.langCode.locale.language,
//          target: end.langCode.locale.language)
//      }
//    })
    .onAppear {
    }
    .task {
      await AudioPermissionFunctor.permission()
      store.send(.getLanguageItems)
    }
    .onDisappear {
      store.send(.teardown)
    }
  }
}
