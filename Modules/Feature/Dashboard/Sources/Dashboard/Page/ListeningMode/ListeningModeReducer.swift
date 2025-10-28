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
        return sideEffect.downloadSpeechModel(item: state.start)

      case .binding:
        return .none

      case .teardown:
        state.reset()
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
        return sideEffect.downloadSpeechModel(item: state.start)

      case .playRecording:
        return sideEffect.startTranscription(itemA: state.start, itemB: state.isAutoDetect ? state.end : .none)
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
        switch item.isFinal {
        case true:
          let item = TranscriptionEntity.Item(
            id: item.id,
            localeA: item.localeA,
            localeB: item.localeB ?? state.end.langCode.locale,
            text: item.text,
            isFinal: true,
            translation: .none,
            createAt: Date().timeIntervalSince1970,
            localeConfidence: item.localeConfidence
          )
          state.contentViewState.finalList.append(item)
          state.contentViewState.draftItem = nil
          return .none

        case false:
          state.contentViewState.draftItem = .init(
            id: item.id,
            localeA: item.localeA,
            localeB: item.localeB ?? state.end.langCode.locale,
            text: item.text,
            isFinal: false,
            createAt: Date().timeIntervalSince1970,
            localeConfidence: item.localeConfidence
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

    var start: LanguageEntity.Item = .init(langCode: .english, status: .installed)
    var end: LanguageEntity.Item = .init(langCode: .korean, status: .installed)
    var fetchLanguageItemList = FetchState.Data<[LanguageEntity.Item]>(isLoading: false, value: [])
    var contentViewState = ListeningModePage.ContentList.ViewState()
    var downloadProgress: Double? = .none
    var isPlay = false
    var isAutoDetect = false
    var roomInformation: RoomInformation? = .none

    mutating func reset() {
      fetchLanguageItemList = FetchState.Data<[LanguageEntity.Item]>(isLoading: false, value: [])
      downloadProgress = .none
      contentViewState = ListeningModePage.ContentList.ViewState()
      isPlay = false
      roomInformation = .none
    }
  }

  public enum Action: Equatable, BindableAction, Sendable {
    case binding(BindingAction<State>)
    case teardown

    case getLanguageItems
    case updateItem(TranscriptionEntity.Item)
    case updateStartLanguageItem(LanguageEntity.Item)

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
      id: UUID().uuidString,
      localeA: localeA,
      localeB: localeB,
      text: text,
      isFinal: true,
      translation: .none,
      createAt: Date.timeIntervalBetween1970AndReferenceDate,
      localeConfidence: localeConfidence
    )
  }
}
