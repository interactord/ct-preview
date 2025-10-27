import Foundation
import Domain

public extension Result where Failure == CompositeError {
  /// Wrap an async throwing operation into a Result
  static func catching(_ work: () async throws -> Success) async -> Result<Success, Failure> {
    do { return .success(try await work()) }
    catch { return .failure(error.serialized()) }
  }

  /// Wrap an async throwing operation into a Result and map the thrown error to a specific Failure
  static func catching(
    _ work: () async throws -> Success,
    mapError: (Error) -> Failure
  ) async -> Result<Success, Failure> {
    do { return .success(try await work()) }
    catch { return .failure(mapError(error)) }
  }
}

public extension Result where Failure == CompositeError {
  /// Convenience to get the success value or rethrow
  func value() throws -> Success {
    switch self {
    case let .success(value): return value
    case let .failure(error): throw error.serialized()
    }
  }
}
