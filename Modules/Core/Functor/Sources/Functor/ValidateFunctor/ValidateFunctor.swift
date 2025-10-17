import Foundation

public enum ValidateFunctor {
  public static func emailValidate(value: String) -> Bool {
    let regex = #"^\S+@\S+\.\S{2,}+$"#
    let pred = NSPredicate(format: "SELF MATCHES %@", regex)
    return pred.evaluate(with: value)
  }

  public static func nicknameValidate(value: String) -> Bool {
    let regex = #"[0-9a-zA-Z]{1,}"#
    let pred = NSPredicate(format: "SELF MATCHES %@", regex)
    return pred.evaluate(with: value)
  }

  public static func roomPasswordValidate(value: String) -> Bool {
    let regex = #"[0-9a-zA-Z]{5,12}"#
    let pred = NSPredicate(format: "SELF MATCHES %@", regex)
    return pred.evaluate(with: value)
  }
}
