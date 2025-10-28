import Architecture
import ComposableArchitecture
import Domain
import Foundation
import Functor
import LinkNavigatorSwiftUI
import CoreMedia

// MARK: - ListeningModeSideEffect

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


  func routeToHistoryList() -> Effect<ListeningModeReducer.Action> {
    .run { send in
      await navigator.next(item: .init(path: Link.Dashboard.Path.roomList.rawValue, items: .none))
      await send(.none)
    }
  }

  func fetchLanguageItemList() -> Effect<ListeningModeReducer.Action> {
    .run { send in
      let newItem: [LanguageEntity.Item] = await LanguageEntity.LangCode.allCases.asyncMap { langCode in
        switch await SpeechFunctor(locale: langCode.locale).getModelStatus() {
        case .notSupported:
          .init(langCode: langCode, status: .notSupported)
        case .installed:
          .init(langCode: langCode, status: .installed)
        case .notInstalled:
          .init(langCode: langCode, status: .notInstalled)
        }
      }
      let filterItem = newItem.filter { $0.status != .notSupported }
      await send(.fetchLanguageItemList(.success(filterItem)))
    }
  }

  func downloadSpeechModel(item: LanguageEntity.Item) -> Effect<ListeningModeReducer.Action> {
    .run { send in
      let functor = SpeechFunctor(locale: item.langCode.locale)
      guard await !functor.installed(locale: item.langCode.locale) else {
        await send(.set(\.downloadProgress, .none))
        return await send(.none)
      }

      await functor.releaseLocales()
      for try await progress in functor.downloadIfNeeded().distinctUntilChanged() {
        await send(.set(\.downloadProgress, progress))
      }
      await send(.set(\.downloadProgress, .none))
      await send(.getLanguageItems)
    }
  }

  func startTranscription(itemA: LanguageEntity.Item, itemB: LanguageEntity.Item?) -> Effect<ListeningModeReducer.Action> {
    .run { send in
      await send(.set(\.isPlay, true))

      do {
        for try await item in try await useCaseGroup.transcriptionUseCase.transcript(itemA: itemA, itemB: itemB) {
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

  func createOrUpdateRoomInformation(
    room: RoomInformation?,
    item: TranscriptionEntity.Item
  ) -> Effect<ListeningModeReducer.Action> {
    .run { send in
      guard let translation = item.translation else { return await send(.none) }

      do {
        let roomInfo: RoomInformation = try await {
          if let info = room { return info }
          return try await useCaseGroup.roomUseCase.save(
            roomInformation: .init(
              id: UUID().uuidString,
              title: translation.text,
              createAt: Date().timeIntervalSince1970,
              itemList: [],
              summery: .none
            )
          )
        }()
        await send(.set(\.roomInformation, roomInfo))
        _ = try await useCaseGroup.roomUseCase.update(roomID: roomInfo.id, item: item)
      } catch {
        await send(.throwError(error.serialized()))
      }
    }
  }

  func diff(list: [TranscriptionEntity.Item], item: TranscriptionEntity.Item) {
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

extension AsyncSequence {
  fileprivate func distinctUntilChanged(
    by areEquivalent: @escaping (Element, Element) -> Bool
  ) -> AsyncDistinctUntilChangedSequence<Self> {
    AsyncDistinctUntilChangedSequence(base: self, areEquivalent: areEquivalent)
  }
}

extension AsyncSequence where Element: Equatable {
  fileprivate func distinctUntilChanged() -> AsyncDistinctUntilChangedSequence<Self> {
    AsyncDistinctUntilChangedSequence(base: self, areEquivalent: ==)
  }
}

private struct AsyncDistinctUntilChangedSequence<Base: AsyncSequence>: AsyncSequence {

  // MARK: Lifecycle

  fileprivate init(base: Base, areEquivalent: @escaping (Element, Element) -> Bool) {
    self.base = base
    self.areEquivalent = areEquivalent
  }

  // MARK: Internal

  let base: Base
  let areEquivalent: (Element, Element) -> Bool

  // MARK: Fileprivate

  fileprivate typealias Element = Base.Element

  fileprivate struct Iterator: AsyncIteratorProtocol {

    // MARK: Internal

    var baseIterator: Base.AsyncIterator
    let areEquivalent: (Element, Element) -> Bool
    var previousEmitted: Element?

    // MARK: Fileprivate

    fileprivate mutating func next() async rethrows -> Element? {
      // 루프를 돌며 직전 값과 다른 첫 요소를 찾아서 emit
      while let nextValue = try await baseIterator.next() {
        if let prev = previousEmitted {
          if !areEquivalent(prev, nextValue) {
            previousEmitted = nextValue
            return nextValue
          } else {
            // 동일하면 스킵하고 다음 요소 탐색
            continue
          }
        } else {
          // 첫 값은 무조건 emit
          previousEmitted = nextValue
          return nextValue
        }
      }
      return nil
    }
  }

  fileprivate func makeAsyncIterator() -> Iterator {
    Iterator(baseIterator: base.makeAsyncIterator(), areEquivalent: areEquivalent, previousEmitted: nil)
  }
}

extension CMTimeRange {
  fileprivate func rangesOverlap(target: CMTimeRange) -> Bool {
    let aStart = start
    let aEnd = start + duration
    let bStart = target.start
    let bEnd = target.start + target.duration
    // 겹침: aEnd > bStart && bEnd > aStart
    return CMTimeCompare(aEnd, bStart) == 1 && CMTimeCompare(bEnd, aStart) == 1
  }
}
