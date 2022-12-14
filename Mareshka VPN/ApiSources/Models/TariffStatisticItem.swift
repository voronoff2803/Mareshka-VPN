//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

public class TariffStatisticItem: APIModel {

    public enum Locale: String, Codable, Equatable, CaseIterable {
        case ru = "RU"
        case en = "EN"
        case cn = "CN"
    }

    public var count: Int?

    public var locale: Locale?

    public var tariffName: String?

    public init(count: Int? = nil, locale: Locale? = nil, tariffName: String? = nil) {
        self.count = count
        self.locale = locale
        self.tariffName = tariffName
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        count = try container.decodeIfPresent("count")
        locale = try container.decodeIfPresent("locale")
        tariffName = try container.decodeIfPresent("tariffName")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(count, forKey: "count")
        try container.encodeIfPresent(locale, forKey: "locale")
        try container.encodeIfPresent(tariffName, forKey: "tariffName")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? TariffStatisticItem else { return false }
      guard self.count == object.count else { return false }
      guard self.locale == object.locale else { return false }
      guard self.tariffName == object.tariffName else { return false }
      return true
    }

    public static func == (lhs: TariffStatisticItem, rhs: TariffStatisticItem) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
