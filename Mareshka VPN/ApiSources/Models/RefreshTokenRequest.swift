//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

public class RefreshTokenRequest: APIModel {

    public var refreshToken: String?

    public init(refreshToken: String? = nil) {
        self.refreshToken = refreshToken
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        refreshToken = try container.decodeIfPresent("refreshToken")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(refreshToken, forKey: "refreshToken")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? RefreshTokenRequest else { return false }
      guard self.refreshToken == object.refreshToken else { return false }
      return true
    }

    public static func == (lhs: RefreshTokenRequest, rhs: RefreshTokenRequest) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
