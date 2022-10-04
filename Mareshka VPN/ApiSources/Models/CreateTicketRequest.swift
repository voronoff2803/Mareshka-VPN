//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

public class CreateTicketRequest: APIModel {

    public var content: String?

    public var email: String?

    public var name: String?

    public var telegram: String?

    public init(content: String? = nil, email: String? = nil, name: String? = nil, telegram: String? = nil) {
        self.content = content
        self.email = email
        self.name = name
        self.telegram = telegram
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        content = try container.decodeIfPresent("content")
        email = try container.decodeIfPresent("email")
        name = try container.decodeIfPresent("name")
        telegram = try container.decodeIfPresent("telegram")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(content, forKey: "content")
        try container.encodeIfPresent(email, forKey: "email")
        try container.encodeIfPresent(name, forKey: "name")
        try container.encodeIfPresent(telegram, forKey: "telegram")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? CreateTicketRequest else { return false }
      guard self.content == object.content else { return false }
      guard self.email == object.email else { return false }
      guard self.name == object.name else { return false }
      guard self.telegram == object.telegram else { return false }
      return true
    }

    public static func == (lhs: CreateTicketRequest, rhs: CreateTicketRequest) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
