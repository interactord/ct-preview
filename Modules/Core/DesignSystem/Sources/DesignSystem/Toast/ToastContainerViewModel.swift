import Foundation
import SwiftUI

// MARK: - ToastContainerViewModel

@Observable
public final class ToastContainerViewModel {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public var toastMessage: ToastItem? = .none

  // MARK: Private

  private var toastTask: Task<Void, Never>?
}

// MARK: ToastViewModelType

extension ToastContainerViewModel {
  @MainActor
  public func send(toastMessage: String, accessory: ToastItem.AccessoryType? = .none) async {
    cancel()

    toastTask = Task { @MainActor in
      self.toastMessage = .init(message: toastMessage, accessory: accessory)
      do {
        try await Task.sleep(for: .seconds(2.5))
      } catch {
        return
      }
      self.toastMessage = .none
    }
  }

  @MainActor
  public func cancel() {
    toastTask?.cancel()
    toastTask = .none
  }
}

// MARK: - ToastItem

public struct ToastItem: Equatable, Sendable {
  public let message: String
  public let id: String
  public let accessory: AccessoryType?

  public init(message: String, id: String = UUID().uuidString, accessory: AccessoryType? = .none) {
    self.message = message
    self.id = id
    self.accessory = accessory
  }

  public enum AccessoryType: Equatable, Sendable {
    case image(Image)
  }
}
