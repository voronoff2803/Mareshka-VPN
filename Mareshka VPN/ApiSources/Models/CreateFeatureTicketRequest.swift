//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

public class CreateFeatureTicketRequest: APIModel {

    public var content: String?

    public var title: String?

    public init(content: String? = nil, title: String? = nil) {
        self.content = content
        self.title = title
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        content = try container.decodeIfPresent("content")
        title = try container.decodeIfPresent("title")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(content, forKey: "content")
        try container.encodeIfPresent(title, forKey: "title")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? CreateFeatureTicketRequest else { return false }
      guard self.content == object.content else { return false }
      guard self.title == object.title else { return false }
      return true
    }

    public static func == (lhs: CreateFeatureTicketRequest, rhs: CreateFeatureTicketRequest) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
