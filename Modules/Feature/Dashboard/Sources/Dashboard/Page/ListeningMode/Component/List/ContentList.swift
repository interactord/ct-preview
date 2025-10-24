import Foundation
import SwiftUI
import Domain
import Functor

@available(iOS 26.0, *)
extension ListeningModePage {
  struct ContentList {
    var viewState: ViewState
    var updateAction: (TranscriptionEntity.Item) -> Void

    @Namespace var lastItem
  }
}

extension ListeningModePage.ContentList {
  struct ViewState: Equatable, Sendable {
    var finalList: [TranscriptionEntity.Item]
    var draftItem: TranscriptionEntity.Item?

    init(finalList: [TranscriptionEntity.Item] = [], draftItem: TranscriptionEntity.Item? = nil) {
      self.finalList = finalList
      self.draftItem = draftItem
    }
  }
}

extension ListeningModePage.ContentList: View {
  var body: some View {
    VStack {
      ScrollViewReader { proxy in
        List {
          ForEach(viewState.finalList) { item in
            ListeningModePage.ContentItem(
              focusItemList: viewState.finalList.focusedHistory(historyCount: 10, center: item),
              updateAction: updateAction)
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
    .onAppear {
      
    }
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
