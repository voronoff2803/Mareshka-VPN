//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

public class GoogleAuthRequest: APIModel {

    public var credentials: String

    public var deviceId: String

    public var email: String

    public var web: Bool?

    public init(credentials: String, deviceId: String, email: String, web: Bool? = nil) {
        self.credentials = credentials
        self.deviceId = deviceId
        self.email = email
        self.web = web
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        credentials = try container.decode("credentials")
        deviceId = try container.decode("deviceId")
        email = try container.decode("email")
        web = try container.decodeIfPresent("web")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encode(credentials, forKey: "credentials")
        try container.encode(deviceId, forKey: "deviceId")
        try container.encode(email, forKey: "email")
        try container.encodeIfPresent(web, forKey: "web")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? GoogleAuthRequest else { return false }
      guard self.credentials == object.credentials else { return false }
      guard self.deviceId == object.deviceId else { return false }
      guard self.email == object.email else { return false }
      guard self.web == object.web else { return false }
      return true
    }

    public static func == (lhs: GoogleAuthRequest, rhs: GoogleAuthRequest) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
