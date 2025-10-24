import Foundation

public struct RemoteError: Equatable, Codable, Sendable {

  public init(code: Int?, message: String?) {
    self.code = code
    self.message = message
  }

  public let code: Int?
  public let message: String?

  private enum CodingKeys: String, CodingKey {
    case code
    case message
  }
}
