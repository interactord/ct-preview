import AVFoundation
import Foundation

public enum AudioPermissionFunctor {
  @discardableResult
  public static func permission() async -> Bool {
    await AVCaptureDevice.requestAccess(for: .audio)
  }
}
