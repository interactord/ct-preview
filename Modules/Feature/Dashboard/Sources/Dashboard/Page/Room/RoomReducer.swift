import Architecture
import ComposableArchitecture
import Domain
import Foundation

// MARK: - RoomReducer

@Reducer
public struct RoomReducer {

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

      case .routeToBack:
        return sideEffect.routeToBack()

      case .routeToSummerySheet:
        state.route = .summerySheet
        return .none

      case .routeClear:
        state.route = .none
        return .none

      case .getSummery:
        guard state.item.summery == .none else { return .none }
        return sideEffect.summeryContent(item: state.item)

      case .throwError(let error):
        sideEffect.useCaseGroup.loggingUseCase.error(error)
        return .none

      case .none:
        return .none
      }
    }
  }

  // MARK: Internal

  let sideEffect: RoomSideEffect
}

extension RoomReducer {

  @ObservableState
  public struct State: Equatable, Identifiable {
    public let id = UUID()

    var item: RoomInformation
    var route: Route? = .none
  }

  public enum Action: Equatable, BindableAction, Sendable {
    case binding(BindingAction<State>)
    case teardown

    case routeToBack
    case routeToSummerySheet
    case routeClear
    case getSummery

    case throwError(CompositeError)
    case none
  }
}

extension RoomReducer {

  // MARK: Internal

  @CasePathable
  enum Route: Equatable {
    case summerySheet
  }

  // MARK: Private

  private enum CancelID: Equatable, CaseIterable {
    case teardown
  }

}
