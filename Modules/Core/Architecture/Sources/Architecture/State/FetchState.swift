import Foundation

// MARK: - FetchState

public enum FetchState { }

// MARK: FetchState.Empty

extension FetchState {
  public struct Empty: Equatable, Sendable {
    public init(isLoading: Bool) {
      self.isLoading = isLoading
    }

    public init() {
      isLoading = false
    }

    public static var `default`: Self {
      .init(isLoading: false)
    }

    public var isLoading = false

    public func mutate(isLoading: Bool) -> Self {
      .init(isLoading: isLoading)
    }

  }
}

// MARK: FetchState.Data

extension FetchState {
  public struct Data<V: Equatable & Sendable>: Equatable, Sendable {
    public init(isLoading: Bool, value: V) {
      self.isLoading = isLoading
      self.value = value
    }

    public var isLoading = false
    public var value: V

    public func mutate(isLoading: Bool) -> Self {
      .init(isLoading: isLoading, value: value)
    }

    public func mutate(value: V) -> Self {
      .init(isLoading: isLoading, value: value)
    }
  }
}
