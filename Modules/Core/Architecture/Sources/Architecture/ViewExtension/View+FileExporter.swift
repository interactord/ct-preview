import CasePaths
import SwiftUI
import UniformTypeIdentifiers

extension View {

  public func fileExporter<Enum: Sendable, Case>(
    unwrapping enum: Binding<Enum?>,
    case caseKeyPath: CaseKeyPath<Enum, Case>,
    contentType: UTType,
    defaultFilename: String? = nil,
    onCompletion: @escaping (Case, Result<URL, Error>) -> Void)
    -> some View where Case: FileDocument
  {
    let caseBinding = `enum`.case(caseKeyPath)

    let isPresented = Binding<Bool>(
      get: { caseBinding.wrappedValue != nil },
      set: { newValue in
        if !newValue {
          `enum`.wrappedValue = nil
        }
      })

    return fileExporter(
      isPresented: isPresented,
      document: caseBinding.wrappedValue,
      contentType: contentType,
      defaultFilename: defaultFilename)
    { result in
      if let value = caseBinding.wrappedValue {
        onCompletion(value, result)
      }
      `enum`.wrappedValue = nil
    }
  }

  public func fileExporter<Enum: Sendable, Case>(
    unwrapping enum: Binding<Enum?>,
    case caseKeyPath: CaseKeyPath<Enum, Case>,
    contentType: UTType,
    filename: @escaping ((Case?) -> String?),
    onCompletion: @escaping (Case, Result<URL, Error>) -> Void)
    -> some View where Case: FileDocument
  {
    let caseBinding = `enum`.case(caseKeyPath)

    let isPresented = Binding<Bool>(
      get: { caseBinding.wrappedValue != nil },
      set: { newValue in
        if !newValue {
          `enum`.wrappedValue = nil
        }
      })

    return fileExporter(
      isPresented: isPresented,
      document: caseBinding.wrappedValue,
      contentType: contentType,
      defaultFilename: filename(caseBinding.wrappedValue))
    { result in
      if let value = caseBinding.wrappedValue {
        onCompletion(value, result)
      }
      `enum`.wrappedValue = nil
    }
  }
}
