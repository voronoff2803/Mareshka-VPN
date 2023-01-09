//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

public class EditMainPageAdRequest: APIModel {

    public var file: File?

    public init(file: File? = nil) {
        self.file = file
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        file = try container.decodeIfPresent("file")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(file, forKey: "file")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? EditMainPageAdRequest else { return false }
      guard self.file == object.file else { return false }
      return true
    }

    public static func == (lhs: EditMainPageAdRequest, rhs: EditMainPageAdRequest) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
