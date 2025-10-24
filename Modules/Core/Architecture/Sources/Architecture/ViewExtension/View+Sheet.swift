import CasePaths
import SwiftUI

extension View {

  public func sheet<Enum: Sendable, Case>(
    unwrapping enum: Binding<Enum?>,
    case caseKeyPath: CaseKeyPath<Enum, Case>,
    @ViewBuilder content: @escaping (Case) -> some View
  ) -> some View {
    sheet(
      isPresented: .constant(`enum`.case(caseKeyPath).wrappedValue != nil),
      content: { `enum`.case(caseKeyPath).wrappedValue.map(content) }
    )
  }

}

extension Binding {
  public func `case`<Enum: Sendable, Case>(_ caseKeyPath: CaseKeyPath<Enum, Case>) -> Binding<Case?> where Value == Enum? {
    .init(
      get: { self.wrappedValue.flatMap(AnyCasePath(caseKeyPath).extract(from:)) },
      set: { newValue, transaction in
        self.transaction(transaction).wrappedValue = newValue.map(AnyCasePath(caseKeyPath).embed)
      }
    )
  }
}

// MARK: - KeyPath + Sendable

extension KeyPath: @unchecked @retroactive Sendable { }
