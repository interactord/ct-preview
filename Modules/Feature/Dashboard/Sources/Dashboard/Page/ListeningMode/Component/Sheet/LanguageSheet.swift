import Foundation
import SwiftUI
import Domain
import Functor

struct LanguageSheet {
  let selectItem: LanguageEntity.Item?
  let itemList: [LanguageEntity.Item]
  let selectAction: (LanguageEntity.Item) -> Void
}

extension LanguageSheet: View {
  var body: some View {
    NavigationView {
      ScrollView {
        VStack {
          ForEach(itemList) { item in
            LanguageSheetItem(
              item: item,
              selectItem: selectItem,
              selectAction: selectAction)
          }
        }
      }
      .navigationTitle("언어 선택")
      .navigationBarTitleDisplayMode(.inline)
    }

  }
}


private struct LanguageSheetItem {
  let item: LanguageEntity.Item
  let selectItem: LanguageEntity.Item?
  let selectAction: (LanguageEntity.Item) -> Void
  @State private var isDownload = false
  @State private var progress: Double = .zero
}

extension LanguageSheetItem {
  private var stateImage: String {
    switch item.status {
    case .notInstalled: "arrow.down.circle"
    case .installed: "checkmark.circle.fill"
    case .notSupported: "x.circle.fill"
    }
  }
}

extension LanguageSheetItem: View {
  var body: some View {
    HStack {
      Text(item.langCode.modelName)
        .foregroundColor(selectItem == item ? .accentColor : .primary)
      Spacer()
      switch isDownload {
      case true:
        ProgressView(value: progress, total: 1.0)
      case false:
        Image(systemName: stateImage)
      }
    }
    .onTapGesture {
      selectAction(item)
    }
    .padding(16)
  }
}
