//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

public class StartEmailVerificationRequest: APIModel {

    public var email: String

    public init(email: String) {
        self.email = email
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        email = try container.decode("email")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encode(email, forKey: "email")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? StartEmailVerificationRequest else { return false }
      guard self.email == object.email else { return false }
      return true
    }

    public static func == (lhs: StartEmailVerificationRequest, rhs: StartEmailVerificationRequest) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}