import Architecture
import ComposableArchitecture
import Domain
import Foundation
import LinkNavigatorSwiftUI
import Functor

// MARK: - SplashSideEffect

struct ListeningModeSideEffect: Sendable {
  let navigator: SingleNavigator
  let useCaseGroup: DashboardUseCaseGroup
}

extension ListeningModeSideEffect {

  func routeToBack() -> Effect<ListeningModeReducer.Action> {
    .run { send in
      await navigator.back()
      await send(.none)
    }
  }

  func fetchLanguageItemList() -> Effect<ListeningModeReducer.Action> {
    .run { send in
      let newItem: [LanguageEntity.Item] = await LanguageEntity.LangCode.allCases.asyncMap { langCode in
        switch await SpeechFunctor(locale: langCode.locale).getModelStatus() {
        case .notSupported:
          return .init(langCode: langCode, status: .notSupported)
        case .installed:
          return .init(langCode: langCode, status: .installed)
        case .notInstalled:
          return .init(langCode: langCode, status: .notInstalled)
        }
      }
      let filterItem = newItem.filter { $0.status != .notSupported }
      await send(.fetchLanguageItemList(.success(filterItem)))
    }
  }

  func downloadSpeechModel(item: LanguageEntity.Item) -> Effect<ListeningModeReducer.Action> {
    .run { send in
      let functor = SpeechFunctor(locale: item.langCode.locale)
      Task {
        for try await progress in functor.downloadIfNeeded() {
          print(progress)
        }
      }
      await send(.set(\.route, .none))
    }
  }

  func startTranscription(item: LanguageEntity.Item) -> Effect<ListeningModeReducer.Action> {
    .run { send in
      await send(.set(\.isPlay, true))

      do {
        for try await item in try await useCaseGroup.transcriptionUseCase.transcript(item: item) {
          await send(.fetchTranscriptItem(item))
        }
      } catch {
        await send(.set(\.isPlay, false))
        await send(.throwError(error.serialized()))
      }
    }
  }

  func forceStopTranscription() -> Effect<ListeningModeReducer.Action> {
    .run { send in
      do {
        try await useCaseGroup.transcriptionUseCase.stop()
        await send(.set(\.isPlay, false))
        await send(.none)
      } catch {
        await send(.set(\.isPlay, false))
        await send(.throwError(error.serialized()))
      }

    }
  }
}


extension Sequence {
  fileprivate func asyncMap<T>(_ transform: (Element) async throws -> T) async rethrows -> [T] {
    var results = [T]()
    for element in self {
      let value = try await transform(element)
      results.append(value)
    }
    return results
  }
}
