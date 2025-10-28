import Architecture
import ComposableArchitecture
import Domain
import Foundation

// MARK: - RoomListReducer

@Reducer
public struct RoomListReducer {

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

      case .getRoomList:
        state.fetchRoomList.isLoading = true
        return sideEffect.getRoomList()
          .cancellable(pageID: state.id, id: CancelID.requestRoomList, cancelInFlight: true)

      case .routeToRoomDetail(let item):
        return sideEffect.routeToRoomDetail(item: item)

      case .routeToBack:
        return sideEffect.routeToBack()

      case .deleteAllItem:
        return sideEffect.deleteAllItem()

      case .deleteItem(let item):
        return sideEffect.delete(item: item)

      case .fetchRoomList(let result):
        state.fetchRoomList.isLoading = false
        switch result {
        case .success(let list):
          state.fetchRoomList.value = list
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .throwError(let error):
        sideEffect.useCaseGroup.loggingUseCase.error(error)
        return .none

      case .none:
        return .none
      }
    }
  }

  // MARK: Internal

  let sideEffect: RoomListSideEffect
}

extension RoomListReducer {

  @ObservableState
  public struct State: Equatable, Identifiable {
    public let id = UUID()

    var fetchRoomList = FetchState.Data<[RoomInformation]>(isLoading: false, value: [])
  }

  public enum Action: Equatable, BindableAction, Sendable {
    case binding(BindingAction<State>)
    case teardown

    case getRoomList
    case routeToRoomDetail(RoomInformation)
    case routeToBack

    case deleteAllItem
    case deleteItem(RoomInformation)

    case fetchRoomList(Result<[RoomInformation], CompositeError>)
    case throwError(CompositeError)
    case none
  }
}

extension RoomListReducer {
  private enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestRoomList
  }
}
