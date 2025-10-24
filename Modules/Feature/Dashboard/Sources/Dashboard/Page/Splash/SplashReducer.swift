import Architecture
import ComposableArchitecture
import Domain
import Foundation

// MARK: - SplashReducer

@Reducer
public struct SplashReducer {

  // MARK: Public

  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .teardown:
        return .concatenate(
          CancelID.allCases.map { .cancel(pageID: state.id, id: $0) }
        )

      case .routeToListeningMode:
        return sideEffect.routeToListeningModePage()

      case .throwError(let error):
        sideEffect.useCaseGroup.loggingUseCase.error(error)
        return .none

      case .none:
        return .none
      }
    }
  }

  // MARK: Internal

  let sideEffect: SplashSideEffect
}

extension SplashReducer {
  @ObservableState
  public struct State: Equatable, Identifiable {
    public let id = UUID()
  }

  public enum Action: Equatable, BindableAction, Sendable {
    case binding(BindingAction<State>)
    case teardown

    case routeToListeningMode

    case throwError(CompositeError)
    case none
  }
}

extension SplashReducer {

  // MARK: Public

  public enum Route: Equatable, Sendable { }

  // MARK: Private

  private enum CancelID: Equatable, CaseIterable {
    case teardown
  }

}
