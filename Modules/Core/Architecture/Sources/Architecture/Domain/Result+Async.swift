import Domain
import Foundation

extension Result where Failure == CompositeError {
  /// Wrap an async throwing operation into a Result
  public static func catching(_ work: () async throws -> Success) async -> Result<Success, Failure> {
    do { return .success(try await work()) }
    catch { return .failure(error.serialized()) }
  }

  /// Wrap an async throwing operation into a Result and map the thrown error to a specific Failure
  public static func catching(
    _ work: () async throws -> Success,
    mapError: (Error) -> Failure
  ) async -> Result<Success, Failure> {
    do { return .success(try await work()) }
    catch { return .failure(mapError(error)) }
  }
}

extension Result where Failure == CompositeError {
  /// Convenience to get the success value or rethrow
  public func value() throws -> Success {
    switch self {
    case .success(let value): return value
    case .failure(let error): throw error.serialized()
    }
  }
}
