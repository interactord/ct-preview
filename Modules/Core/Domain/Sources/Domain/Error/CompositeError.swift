import Foundation

// MARK: - CompositeError

public enum CompositeError: Error, Sendable {

  case invalidTypeCasting
  case timeout
  case networkOffline
  case networkUnauthorized
  case networkUnknown
  case networkRemoteFail(RemoteError)
  case networkNotFound
  case other(Error)
  case userCancelled
  case stopSpeech
  case webSocketDisconnect
  case audioProcessFail(String)
  case fileDuplicate

  // MARK: Public

  public var displayMessage: String {
    switch self {
    case .networkOffline:
      "Wifi is offline. please reconnect the wifi."
    case .networkRemoteFail(let domain):
      domain.message ?? ""
    case .userCancelled:
      "User Canceled"
    case .stopSpeech: ""
    case .audioProcessFail(let message): message
    default:
      localizedDescription
    }
  }
}

// MARK: Equatable

extension CompositeError: Equatable {
  public var isNetworkUnauthorized: Bool {
    switch self {
    case .networkRemoteFail(let domain) where domain.code == 401:
      true
    case .networkRemoteFail(let domain) where domain.code == 4100:
      true
    case .networkRemoteFail(let domain) where domain.code == 40100:
      true
    case .networkUnauthorized:
      true
    default:
      false
    }
  }

  public var isExpiredCard: Bool {
    switch self {
    case .networkRemoteFail(let domain) where domain.code == 7003:
      true
    default:
      false
    }
  }

  public var isLimitCount: Bool {
    switch self {
    case .networkRemoteFail(let domain) where [24201, 24202].contains(domain.code):
      true
    default:
      false
    }
  }

  public var isNotExist: Bool {
    switch self {
    case .networkRemoteFail(let domain) where domain.code == 40010:
      true
    default:
      false
    }
  }

  public var isNeedChatRoomPassword: Bool {
    switch self {
    case .networkRemoteFail(let domain) where domain.code == 40301:
      true
    default:
      false
    }
  }

  public var isSameTranslationLangCode: Bool {
    switch self {
    case .networkRemoteFail(let domain) where domain.code == 40006:
      true
    default:
      false
    }
  }

  public var isExpiredTrial: Bool {
    switch self {
    case .networkRemoteFail(let domain) where domain.code == 40101:
      true
    default:
      false
    }
  }

  public var isForcedLogoutByAnotherDeviceLogIn: Bool {
    switch self {
    case .networkRemoteFail(let domain) where domain.code == 40100:
      HTTPCookieStorage.shared.cookies?.count ?? 1 > .zero
    default:
      false
    }
  }

  public var isAlreadyLoggedInAnotherDevice: Bool {
    switch self {
    case .networkRemoteFail(let domain) where domain.code == 40901:
      true
    default:
      false
    }
  }

  public var isNotCorrectAccountOrPW: Bool {
    switch self {
    case .networkRemoteFail(let domain) where domain.code == 40004:
      true
    default:
      false
    }
  }

  public static func ==(lhs: Self, rhs: Self) -> Bool {
    lhs.displayMessage == rhs.displayMessage
  }

}

// MARK: CompositeError.Folder

extension CompositeError {
  public struct Folder: Equatable {
    public init(parentsID: String, folderName: String, driveID: String) {
      self.parentsID = parentsID
      self.folderName = folderName
      self.driveID = driveID
    }

    public var parentsID: String
    public var folderName: String
    public var driveID: String

  }
}

extension Error {
  public func serialized() -> CompositeError {
    guard let err = self as? CompositeError
    else { return .other(self) }
    return err
  }
}
