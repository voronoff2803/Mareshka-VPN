//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

public class CreateServerRequest: APIModel {

    public var address: String?

    public var cert: String?

    public var city: String?

    public var country: String?

    public var countryCode: String?

    public init(address: String? = nil, cert: String? = nil, city: String? = nil, country: String? = nil, countryCode: String? = nil) {
        self.address = address
        self.cert = cert
        self.city = city
        self.country = country
        self.countryCode = countryCode
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        address = try container.decodeIfPresent("address")
        cert = try container.decodeIfPresent("cert")
        city = try container.decodeIfPresent("city")
        country = try container.decodeIfPresent("country")
        countryCode = try container.decodeIfPresent("countryCode")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(address, forKey: "address")
        try container.encodeIfPresent(cert, forKey: "cert")
        try container.encodeIfPresent(city, forKey: "city")
        try container.encodeIfPresent(country, forKey: "country")
        try container.encodeIfPresent(countryCode, forKey: "countryCode")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? CreateServerRequest else { return false }
      guard self.address == object.address else { return false }
      guard self.cert == object.cert else { return false }
      guard self.city == object.city else { return false }
      guard self.country == object.country else { return false }
      guard self.countryCode == object.countryCode else { return false }
      return true
    }

    public static func == (lhs: CreateServerRequest, rhs: CreateServerRequest) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
