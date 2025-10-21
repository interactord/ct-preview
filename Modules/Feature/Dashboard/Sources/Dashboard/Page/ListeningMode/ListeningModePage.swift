import ComposableArchitecture
import Domain
import LinkNavigatorSwiftUI
import SwiftUI
import DesignSystem
import Functor
import Architecture
import Translation

// MARK: - SplashPage

struct ListeningModePage {

  init(store: StoreOf<ListeningModeReducer>) {
    self.store = store
  }

  @Bindable private var store: StoreOf<ListeningModeReducer>
  @State private var configuration: TranslationSession.Configuration?
}

extension ListeningModePage {
}

// MARK: View

extension ListeningModePage: View {

  var body: some View {
    VStack {
      HStack {
        Spacer()
        Button(action: { store.send(.routeToStartLanguageItem) }) {
          switch store.languageInfo.start {
          case .none:
            Text("언어를 선택해주세요")
          case .some(let value):
            Text(value.langCode.modelName)
          }
        }

        Image(systemName: "arrow.right")
        Button(action: { store.send(.routeToEndLanguageItem) }) {
          switch store.languageInfo.end {
          case .none:
            Text("언어를 선택해주세요")
          case .some(let value):
            Text(value.langCode.modelName)
          }
        }
        Spacer()
      }
      ContentList(
        viewState: store.contentViewState,
        updateAction: { store.send(.updateItem($0)) })
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
            .frame(width: 80, height: 80)
        }
        .tint(store.isPlay ?  Color.accentColor : SystemColor.Label.OnBG.primary.color)

        Spacer()
      }
    }
    .background(.background)
    .sheet(
      unwrapping: $store.route,
      case: \.startSheet,
      content: { _ in
          LanguageSheet(
            selectItem: store.languageInfo.start,
            itemList: store.fetchLanguageItemList.value,
            selectAction: { store.send(.selectStartItem($0)) })

    })
    .sheet(
      unwrapping: $store.route,
      case: \.endSheet,
      content: { _ in
          LanguageSheet(
            selectItem: store.languageInfo.end,
            itemList: store.fetchLanguageItemList.value,
            selectAction: { store.send(.selectEndItem($0)) })

    })
    .onAppear {
    }
    .onChange(of: store.languageInfo, { _, new in
      guard let start = new.start, let end = new.end else { return }
      Task {
        try? await Task.sleep(for: .seconds(1))
        configuration = .init(
          source: start.langCode.locale.language,
          target: end.langCode.locale.language)
      }
    })
    .translationTask(configuration) { session in
      Task {
        do {
          try await session.prepareTranslation()
        } catch {
          print("[ERRRRRRRRR] \(error)")
        }
      }
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
