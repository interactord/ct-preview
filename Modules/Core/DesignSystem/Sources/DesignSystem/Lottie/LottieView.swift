import Lottie
import SwiftUI

// MARK: - Lottie

public struct Lottie: View {

  // MARK: Lifecycle

  public init(
    lottieType: LottieType,
    loopType: LoopType,
    completionAction: @escaping () -> Void = { }
  ) {
    self.lottieType = lottieType
    self.loopType = loopType
    self.completionAction = completionAction
  }

  // MARK: Public

  public var body: some View {
    LottieView(animation: lottieType.lottieAnimation)
      .playing(loopMode: loopMode)
      .animationDidFinish { completed in
        guard completed else { return }
        completionAction()
      }
  }

  // MARK: Internal

  let lottieType: LottieType
  let loopType: LoopType
  let completionAction: () -> Void
}

extension Lottie {
  public var loopMode: LottieLoopMode {
    switch loopType {
    case .once:
      .playOnce
    case .infinite:
      .loop
    }
  }
}

// MARK: - LottieType

extension Lottie {
  public enum LottieType: Equatable {
    case requestFlighting
    case splash
    case splashDark
    case anyTypingDark
    case anyTypingLight

    // MARK: Fileprivate

    fileprivate var lottieAnimation: LottieAnimation? {
      switch self {
      case .requestFlighting:
        .named("loading", bundle: Bundle.module)
      case .splash:
        .named("splash_light", bundle: Bundle.module)
      case .splashDark:
        .named("splash_dark", bundle: Bundle.module)
      case .anyTypingDark:
        .named("ani_typing_dark", bundle: Bundle.module)
      case .anyTypingLight:
        .named("ani_typing_light", bundle: .module)
      }
    }
  }

  public enum LoopType: Equatable {
    case once
    case infinite
  }
}
