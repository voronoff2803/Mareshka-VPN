//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

public class PageResponseAnonymousUserDTO: APIModel {

    public var data: [AnonymousUserDTO]?

    public var page: Int?

    public var pageCount: Int?

    public var totalElements: Int?

    public init(data: [AnonymousUserDTO]? = nil, page: Int? = nil, pageCount: Int? = nil, totalElements: Int? = nil) {
        self.data = data
        self.page = page
        self.pageCount = pageCount
        self.totalElements = totalElements
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        data = try container.decodeArrayIfPresent("data")
        page = try container.decodeIfPresent("page")
        pageCount = try container.decodeIfPresent("pageCount")
        totalElements = try container.decodeIfPresent("totalElements")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(data, forKey: "data")
        try container.encodeIfPresent(page, forKey: "page")
        try container.encodeIfPresent(pageCount, forKey: "pageCount")
        try container.encodeIfPresent(totalElements, forKey: "totalElements")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? PageResponseAnonymousUserDTO else { return false }
      guard self.data == object.data else { return false }
      guard self.page == object.page else { return false }
      guard self.pageCount == object.pageCount else { return false }
      guard self.totalElements == object.totalElements else { return false }
      return true
    }

    public static func == (lhs: PageResponseAnonymousUserDTO, rhs: PageResponseAnonymousUserDTO) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
