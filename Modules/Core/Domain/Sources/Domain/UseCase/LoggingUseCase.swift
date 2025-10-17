import Foundation

public protocol LoggingUseCase: Sendable {
  func send(_ items: Any...)
  func error(_ items: Any...)
}
