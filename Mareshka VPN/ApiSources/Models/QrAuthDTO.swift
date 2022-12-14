//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

public class QrAuthDTO: APIModel {

    public var id: ID?

    public init(id: ID? = nil) {
        self.id = id
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        id = try container.decodeIfPresent("id")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(id, forKey: "id")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? QrAuthDTO else { return false }
      guard self.id == object.id else { return false }
      return true
    }

    public static func == (lhs: QrAuthDTO, rhs: QrAuthDTO) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
