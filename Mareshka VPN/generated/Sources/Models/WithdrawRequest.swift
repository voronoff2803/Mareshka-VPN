//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

public class WithdrawRequest: APIModel {

    public var card: String?

    public var count: Double?

    public var email: String?

    public init(card: String? = nil, count: Double? = nil, email: String? = nil) {
        self.card = card
        self.count = count
        self.email = email
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        card = try container.decodeIfPresent("card")
        count = try container.decodeIfPresent("count")
        email = try container.decodeIfPresent("email")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(card, forKey: "card")
        try container.encodeIfPresent(count, forKey: "count")
        try container.encodeIfPresent(email, forKey: "email")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? WithdrawRequest else { return false }
      guard self.card == object.card else { return false }
      guard self.count == object.count else { return false }
      guard self.email == object.email else { return false }
      return true
    }

    public static func == (lhs: WithdrawRequest, rhs: WithdrawRequest) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
