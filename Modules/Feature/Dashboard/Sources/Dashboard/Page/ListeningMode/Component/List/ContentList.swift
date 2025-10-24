import Domain
import Foundation
import Functor
import SwiftUI

// MARK: - ListeningModePage.ContentList

@available(iOS 26.0, *)
extension ListeningModePage {
  struct ContentList {
    var viewState: ViewState
    let updateAction: (TranscriptionEntity.Item) -> Void
    let errorAction: (CompositeError) -> Void

    @Namespace var lastItem
  }
}

// MARK: - ListeningModePage.ContentList.ViewState

extension ListeningModePage.ContentList {
  struct ViewState: Equatable, Sendable {
    init(finalList: [TranscriptionEntity.Item] = [], draftItem: TranscriptionEntity.Item? = nil) {
      self.finalList = finalList
      self.draftItem = draftItem
    }

    var finalList: [TranscriptionEntity.Item]
    var draftItem: TranscriptionEntity.Item?

  }
}

// MARK: - ListeningModePage.ContentList + View

extension ListeningModePage.ContentList: View {
  var body: some View {
    VStack {
      ScrollViewReader { proxy in
        List {
          ForEach(viewState.finalList) { item in
            ListeningModePage.ContentItem(
              focusItemList: viewState.finalList.focusedHistory(historyCount: 10, center: item),
              updateAction: updateAction,
              errorAction: errorAction
            )
            .id(item.id)
          }
          if let draftItem = viewState.draftItem {
            HStack {
              Text(draftItem.text)
                .foregroundStyle(.secondary)
              Spacer(minLength: .zero)
            }
            .id(draftItem.id)
          }

          Rectangle()
            .fill(.clear)
            .frame(width: 30, height: 100)
            .listRowSeparator(.hidden)
            .listRowInsets(.none)
            .id(lastItem)
        }
        .scrollContentBackground(.hidden)
        .listRowBackground(Color.clear)
        .listStyle(.plain)
        .onChange(of: viewState.draftItem) { _, new in
          guard new != .none else { return }
          withAnimation(.easeInOut) {
            proxy.scrollTo(lastItem, anchor: .top)
          }
        }
      }
    }
    .onAppear { }
  }
}

extension [TranscriptionEntity.Item] {
  fileprivate func focusedHistory(historyCount: Int, center: TranscriptionEntity.Item) -> [TranscriptionEntity.Item] {
    guard let idx = self.lastIndex(of: center) else { return [] }
    let lowerBound = Swift.max(0, idx - historyCount)
    let upperBound = idx
    return Array(self[lowerBound...upperBound])
  }
}
