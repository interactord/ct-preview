import Architecture
import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct RoomReducer {
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

      case .routeToBack:
        return sideEffect.routeToBack()

      case .throwError(let error):
        sideEffect.useCaseGroup.loggingUseCase.error(error)
        return .none

      case .none:
        return .none
      }
    }
  }

  let sideEffect: RoomSideEffect
}

extension RoomReducer {

  @ObservableState
  public struct State: Equatable, Identifiable {
    public let id = UUID()
    let item: RoomInformation
  }

  public enum Action: Equatable, BindableAction, Sendable {
    case binding(BindingAction<State>)
    case teardown

    case routeToBack

    case throwError(CompositeError)
    case none
  }
}

extension RoomReducer {
  private enum CancelID: Equatable, CaseIterable {
    case teardown
  }
}
