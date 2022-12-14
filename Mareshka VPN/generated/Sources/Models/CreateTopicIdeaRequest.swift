//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

public class CreateTopicIdeaRequest: APIModel {

    public var content: String?

    public init(content: String? = nil) {
        self.content = content
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        content = try container.decodeIfPresent("content")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(content, forKey: "content")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? CreateTopicIdeaRequest else { return false }
      guard self.content == object.content else { return false }
      return true
    }

    public static func == (lhs: CreateTopicIdeaRequest, rhs: CreateTopicIdeaRequest) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
