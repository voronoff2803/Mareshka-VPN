//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

public class GiveUserPermanentRequest: APIModel {

    public var userId: ID?

    public init(userId: ID? = nil) {
        self.userId = userId
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        userId = try container.decodeIfPresent("userId")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(userId, forKey: "userId")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? GiveUserPermanentRequest else { return false }
      guard self.userId == object.userId else { return false }
      return true
    }

    public static func == (lhs: GiveUserPermanentRequest, rhs: GiveUserPermanentRequest) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
