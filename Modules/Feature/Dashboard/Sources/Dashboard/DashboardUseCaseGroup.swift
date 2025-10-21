import Domain
import Foundation
import LinkNavigatorSwiftUI

public protocol DashboardUseCaseGroup: Sendable {
  var loggingUseCase: LoggingUseCase { get }
  var transcriptionUseCase: TranscriptionUseCase { get }
}
