//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

public class SendPushToAllRequest: APIModel {

    public var description: String?

    public var title: String?

    public init(description: String? = nil, title: String? = nil) {
        self.description = description
        self.title = title
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        description = try container.decodeIfPresent("description")
        title = try container.decodeIfPresent("title")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(description, forKey: "description")
        try container.encodeIfPresent(title, forKey: "title")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? SendPushToAllRequest else { return false }
      guard self.description == object.description else { return false }
      guard self.title == object.title else { return false }
      return true
    }

    public static func == (lhs: SendPushToAllRequest, rhs: SendPushToAllRequest) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
