//import CasePaths
//import DesignSystem
//import SwiftUI
//
//extension View {
//  public func customDialog<Enum: Sendable, Case>(
//    unwrapping enum: Binding<Enum?>,
//    case caseKeyPath: CaseKeyPath<Enum, Case>,
//    cornerRadius: CGFloat = 4,
//    @ViewBuilder content: @escaping (Case) -> some View)
//    -> some View
//  {
//    customDialog(
//      isPresented: .constant(`enum`.case(caseKeyPath).wrappedValue != nil),
//      cornerRadius: cornerRadius,
//      dialogContent: { `enum`.case(caseKeyPath).wrappedValue.map(content) })
//  }
//}
