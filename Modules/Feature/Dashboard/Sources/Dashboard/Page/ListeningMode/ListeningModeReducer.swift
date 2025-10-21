import Architecture
import ComposableArchitecture
import Domain
import Foundation

// MARK: - SplashReducer

@Reducer
public struct ListeningModeReducer {

  // MARK: Public

  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .teardown:
        return .concatenate(
          CancelID.allCases.map { .cancel(pageID: state.id, id: $0) })

      case .getLanguageItems:
        state.fetchLanguageItemList.isLoading = true
        return sideEffect.fetchLanguageItemList()

      case .selectStartItem(let item):
        state.languageInfo.start = item
        return sideEffect.downloadSpeechModel(item: item)

      case .selectEndItem(let item):
        state.route = .none
        state.languageInfo.end = item
        return .none

      case .updateItem(let item):
        guard let pickIdx = state.contentViewState.finalList.firstIndex(where: { $0.id == item.id }) else { return .none }
        state.contentViewState.finalList[pickIdx] = item
        return .none

      case .playRecording:
        guard let start = state.languageInfo.start else { return .none }
        guard state.languageInfo.end != .none else { return .none }
        return sideEffect.startTranscription(item: start)
          .cancellable(pageID: state.id, id: CancelID.transcriptionEvent)

      case .stopRecording:
        if let draftItem = state.contentViewState.draftItem {
          state.contentViewState.finalList.append(draftItem.serialized())
          state.contentViewState.draftItem = .none
        }
        return .merge([
          sideEffect.forceStopTranscription(),
          .cancel(pageID: state.id, id: CancelID.transcriptionEvent)
        ])

      case .routeToBack:
        return sideEffect.routeToBack()

      case .routeToStartLanguageItem:
        state.route = .startSheet
        return .none

      case .routeToEndLanguageItem:
        state.route = .endSheet
        return .none

      case .fetchLanguageItemList(let result):
        state.fetchLanguageItemList.isLoading = false
        switch result {
        case .success(let list):
          state.fetchLanguageItemList.value = list
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .fetchTranscriptItem(let item):
        guard let endLanguageItem = state.languageInfo.end else { return .none }
        switch item.isFinal {
        case true:
          let item = TranscriptionEntity.Item(
            uuid: UUID().uuidString,
            startLocale: item.startLocale,
            endLocale: endLanguageItem.langCode.locale,
            text: item.text,
            isFinal: true,
            translation: .none)
          state.contentViewState.finalList.append(item)
          state.contentViewState.draftItem = nil
          return .none

        case false:
          state.contentViewState.draftItem = .init(
            startLocale: item.startLocale,
            endLocale: endLanguageItem.langCode.locale,
            text: item.text,
            isFinal: false)
          return .none
        }

      case .throwError(let error):
        sideEffect.useCaseGroup.loggingUseCase.error(error)
        return .none

      case .none:
        return .none
      }
    }
  }

  // MARK: Internal

  let sideEffect: ListeningModeSideEffect
}

extension ListeningModeReducer {
  @ObservableState
  public struct State: Equatable, Identifiable {
    public let id = UUID()

//    var startLanguageItem: LanguageEntity.Item?
//    var endLanguageItem: LanguageEntity.Item?
    var languageInfo: LanguageInfo = .init()
    var route: Route?

    var fetchLanguageItemList: FetchState.Data<[LanguageEntity.Item]> = .init(isLoading: false, value: [])
    var contentViewState: ListeningModePage.ContentList.ViewState = .init()
    var isPlay = false


  }

  public enum Action: Equatable, BindableAction, Sendable {
    case binding(BindingAction<State>)
    case teardown

    case getLanguageItems
    case selectStartItem(LanguageEntity.Item)
    case selectEndItem(LanguageEntity.Item)
    case updateItem(TranscriptionEntity.Item)

    case playRecording
    case stopRecording

    case routeToBack
    case routeToStartLanguageItem
    case routeToEndLanguageItem

    case fetchLanguageItemList(Result<[LanguageEntity.Item], CompositeError>)
    case fetchTranscriptItem(TranscriptionEntity.Item)

    case throwError(CompositeError)
    case none
  }
}

extension ListeningModeReducer.State {
  struct LanguageInfo: Equatable, Sendable {
    var start: LanguageEntity.Item? = .none
    var end: LanguageEntity.Item? = .none
  }
}

extension ListeningModeReducer {

  // MARK: Public

  @CasePathable
  public enum Route: Equatable, Sendable {
    case startSheet
    case endSheet
  }

  // MARK: Private

  private enum CancelID: Equatable, CaseIterable {
    case teardown
    case transcriptionEvent
  }

}

extension TranscriptionEntity.Item {
  fileprivate func serialized() -> TranscriptionEntity.Item {
    TranscriptionEntity.Item.init(
      uuid: UUID().uuidString,
      startLocale: startLocale,
      endLocale: endLocale,
      text: text,
      isFinal: true,
      translation: .none)
  }
}
