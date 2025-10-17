import Foundation

public struct RemoteError: Equatable, Codable, Sendable {

  public let code: Int?
  public let message: String?

  public init(code: Int?, message: String?) {
    self.code = code
    self.message = message
  }

  private enum CodingKeys: String, CodingKey {
    case code, message
  }
}
