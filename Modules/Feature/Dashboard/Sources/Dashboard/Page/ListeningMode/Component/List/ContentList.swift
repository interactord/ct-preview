import Foundation
import SwiftUI
import Domain

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
    ScrollViewReader { proxy in
      List {
        ForEach(viewState.finalList) { item in
          ListeningModePage.ContentItem(
            item: item,
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

        // 화면 하단에 닿지 않도록 만드는 투명 여백 (구분선/인셋 제거)
        Rectangle()
          .fill(.clear)
          .frame(width: 30, height: 100)
          .listRowSeparator(.hidden)
          .listRowInsets(.none)
          .id(lastItem)
      }
      .listStyle(.plain)
      .onChange(of: viewState.draftItem) { _, new in
        guard new != .none else { return }
        proxy.scrollTo(lastItem, anchor: .center)
      }
    }
  }
}
