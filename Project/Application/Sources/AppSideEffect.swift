import Foundation
import Dashboard
import Domain
import Platform
import LinkNavigatorSwiftUI

struct AppSideEffect: DashboardUseCaseGroup, Sendable, DependencyType {
  let loggingUseCase: LoggingUseCase
}

extension AppSideEffect {
  @MainActor
  static func generate() -> Self {
    let loggingUseCase = LoggingUseCasePlatform()
    return AppSideEffect(
      loggingUseCase: loggingUseCase)
  }
}
