import Architecture
import ComposableArchitecture
import Domain
import Foundation

// MARK: - ListeningModeReducer

@Reducer
public struct ListeningModeReducer {

  // MARK: Public

  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding(\.start):
        guard let start = state.start else { return .none }
        return sideEffect.downloadSpeechModel(item: start)

      case .binding:
        return .none

      case .teardown:
        return .concatenate(
          CancelID.allCases.map { .cancel(pageID: state.id, id: $0) }
        )

      case .getLanguageItems:
        state.fetchLanguageItemList.isLoading = true
        return sideEffect.fetchLanguageItemList()

      case .updateItem(let item):
        guard let pickIdx = state.contentViewState.finalList.firstIndex(where: { $0.id == item.id }) else { return .none }
        state.contentViewState.finalList[pickIdx] = item
        return sideEffect.createOrUpdateRoomInformation(room: state.roomInformation, item: item)

      case .updateStartLanguageItem(let item):
        state.start = item
        guard let start = state.start else { return .none }
        return sideEffect.downloadSpeechModel(item: start)

      case .playRecording:
        guard let start = state.start else { return .none }
        guard state.end != .none else { return .none }
        return sideEffect.startTranscription(item: start)
          .cancellable(pageID: state.id, id: CancelID.transcriptionEvent)

      case .stopRecording:
        if let draftItem = state.contentViewState.draftItem {
          state.contentViewState.finalList.append(draftItem.serialized())
          state.contentViewState.draftItem = .none
        }
        return .merge([
          sideEffect.forceStopTranscription(),
          .cancel(pageID: state.id, id: CancelID.transcriptionEvent),
        ])

      case .routeToBack:
        return sideEffect.routeToBack()

      case .routeToHistoryList:
        return sideEffect.routeToHistoryList()

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
        guard let endLanguageItem = state.end else { return .none }
        switch item.isFinal {
        case true:
          let item = TranscriptionEntity.Item(
            uuid: UUID().uuidString,
            startLocale: item.startLocale,
            endLocale: endLanguageItem.langCode.locale,
            text: item.text,
            isFinal: true,
            translation: .none,
            createAt: Date().timeIntervalSince1970
          )
          state.contentViewState.finalList.append(item)
          state.contentViewState.draftItem = nil
          return .none

        case false:
          state.contentViewState.draftItem = .init(
            startLocale: item.startLocale,
            endLocale: endLanguageItem.langCode.locale,
            text: item.text,
            isFinal: false,
            createAt: Date().timeIntervalSince1970
          )
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

    var start: LanguageEntity.Item? = .init(langCode: .english, status: .installed)
    var end: LanguageEntity.Item? = .init(langCode: .korean, status: .installed)
    var fetchLanguageItemList = FetchState.Data<[LanguageEntity.Item]>(isLoading: false, value: [])
    var contentViewState = ListeningModePage.ContentList.ViewState()
    var downloadProgress: Double? = .none
    var isPlay = false
    var roomInformation: RoomInformation? = .none
  }

  public enum Action: Equatable, BindableAction, Sendable {
    case binding(BindingAction<State>)
    case teardown

    case getLanguageItems
    case updateItem(TranscriptionEntity.Item)
    case updateStartLanguageItem(LanguageEntity.Item?)

    case playRecording
    case stopRecording

    case routeToBack
    case routeToHistoryList

    case fetchLanguageItemList(Result<[LanguageEntity.Item], CompositeError>)
    case fetchTranscriptItem(TranscriptionEntity.Item)

    case throwError(CompositeError)
    case none
  }
}

extension ListeningModeReducer {

  private enum CancelID: Equatable, CaseIterable {
    case teardown
    case transcriptionEvent
  }

}

extension TranscriptionEntity.Item {
  fileprivate func serialized() -> TranscriptionEntity.Item {
    TranscriptionEntity.Item(
      uuid: UUID().uuidString,
      startLocale: startLocale,
      endLocale: endLocale,
      text: text,
      isFinal: true,
      translation: .none,
      createAt: Date.timeIntervalBetween1970AndReferenceDate
    )
  }
}
