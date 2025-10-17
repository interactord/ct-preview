import Domain
import Foundation
import Logging

// MARK: - LoggingUseCasePlatform

public struct LoggingUseCasePlatform: Sendable {
  let logger: Logger

  public init(logger: Logger? = .none) {
    self.logger = logger ?? .init(label: "LoggingUseCasePlatform")
  }
}

// MARK: LoggingUseCase

extension LoggingUseCasePlatform: LoggingUseCase {
  public func send(_ items: Any...) {
    let message = items.map { "\($0)" }.joined(separator: "\n")
    logger.debug(.init(stringLiteral: message))
  }

  public func error(_ items: Any...) {
    let message = items.map { "\($0)" }.joined(separator: "\n")
    logger.error(.init(stringLiteral: message))
  }
}
