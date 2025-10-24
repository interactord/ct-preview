import Dashboard
import Domain
import Foundation
import LinkNavigatorSwiftUI
import Platform

// MARK: - AppSideEffect

struct AppSideEffect: DashboardUseCaseGroup, Sendable, DependencyType {
  let loggingUseCase: LoggingUseCase
  let transcriptionUseCase: TranscriptionUseCase
}

extension AppSideEffect {
  @MainActor
  static func generate() -> Self {
    let loggingUseCase = LoggingUseCasePlatform()
    return AppSideEffect(
      loggingUseCase: loggingUseCase,
      transcriptionUseCase: TranscriptionUseCasePlatform(
        loggingUseCase: loggingUseCase
      )
    )
  }
}
