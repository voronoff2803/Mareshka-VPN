//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

public class UserDTO: APIModel {

    public var balance: Double?

    public var boughtByPromocode: Int?

    public var boughtByPromocodeEarned: Int?

    public var boughtByPromocodeSum: Int?

    public var createdAt: DateTime?

    public var downloaded: Int?

    public var email: String?

    public var id: ID?

    public var personalPromocodeDiscount: Int?

    public var personalPromocodeOwnerBallEarn: Int?

    public var primaryReferral: Bool?

    public var promocode: String?

    public var type: String?

    public var uploaded: Int?

    public init(balance: Double? = nil, boughtByPromocode: Int? = nil, boughtByPromocodeEarned: Int? = nil, boughtByPromocodeSum: Int? = nil, createdAt: DateTime? = nil, downloaded: Int? = nil, email: String? = nil, id: ID? = nil, personalPromocodeDiscount: Int? = nil, personalPromocodeOwnerBallEarn: Int? = nil, primaryReferral: Bool? = nil, promocode: String? = nil, type: String? = nil, uploaded: Int? = nil) {
        self.balance = balance
        self.boughtByPromocode = boughtByPromocode
        self.boughtByPromocodeEarned = boughtByPromocodeEarned
        self.boughtByPromocodeSum = boughtByPromocodeSum
        self.createdAt = createdAt
        self.downloaded = downloaded
        self.email = email
        self.id = id
        self.personalPromocodeDiscount = personalPromocodeDiscount
        self.personalPromocodeOwnerBallEarn = personalPromocodeOwnerBallEarn
        self.primaryReferral = primaryReferral
        self.promocode = promocode
        self.type = type
        self.uploaded = uploaded
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        balance = try container.decodeIfPresent("balance")
        boughtByPromocode = try container.decodeIfPresent("boughtByPromocode")
        boughtByPromocodeEarned = try container.decodeIfPresent("boughtByPromocodeEarned")
        boughtByPromocodeSum = try container.decodeIfPresent("boughtByPromocodeSum")
        createdAt = try container.decodeIfPresent("createdAt")
        downloaded = try container.decodeIfPresent("downloaded")
        email = try container.decodeIfPresent("email")
        id = try container.decodeIfPresent("id")
        personalPromocodeDiscount = try container.decodeIfPresent("personalPromocodeDiscount")
        personalPromocodeOwnerBallEarn = try container.decodeIfPresent("personalPromocodeOwnerBallEarn")
        primaryReferral = try container.decodeIfPresent("primaryReferral")
        promocode = try container.decodeIfPresent("promocode")
        type = try container.decodeIfPresent("type")
        uploaded = try container.decodeIfPresent("uploaded")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(balance, forKey: "balance")
        try container.encodeIfPresent(boughtByPromocode, forKey: "boughtByPromocode")
        try container.encodeIfPresent(boughtByPromocodeEarned, forKey: "boughtByPromocodeEarned")
        try container.encodeIfPresent(boughtByPromocodeSum, forKey: "boughtByPromocodeSum")
        try container.encodeIfPresent(createdAt, forKey: "createdAt")
        try container.encodeIfPresent(downloaded, forKey: "downloaded")
        try container.encodeIfPresent(email, forKey: "email")
        try container.encodeIfPresent(id, forKey: "id")
        try container.encodeIfPresent(personalPromocodeDiscount, forKey: "personalPromocodeDiscount")
        try container.encodeIfPresent(personalPromocodeOwnerBallEarn, forKey: "personalPromocodeOwnerBallEarn")
        try container.encodeIfPresent(primaryReferral, forKey: "primaryReferral")
        try container.encodeIfPresent(promocode, forKey: "promocode")
        try container.encodeIfPresent(type, forKey: "type")
        try container.encodeIfPresent(uploaded, forKey: "uploaded")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? UserDTO else { return false }
      guard self.balance == object.balance else { return false }
      guard self.boughtByPromocode == object.boughtByPromocode else { return false }
      guard self.boughtByPromocodeEarned == object.boughtByPromocodeEarned else { return false }
      guard self.boughtByPromocodeSum == object.boughtByPromocodeSum else { return false }
      guard self.createdAt == object.createdAt else { return false }
      guard self.downloaded == object.downloaded else { return false }
      guard self.email == object.email else { return false }
      guard self.id == object.id else { return false }
      guard self.personalPromocodeDiscount == object.personalPromocodeDiscount else { return false }
      guard self.personalPromocodeOwnerBallEarn == object.personalPromocodeOwnerBallEarn else { return false }
      guard self.primaryReferral == object.primaryReferral else { return false }
      guard self.promocode == object.promocode else { return false }
      guard self.type == object.type else { return false }
      guard self.uploaded == object.uploaded else { return false }
      return true
    }

    public static func == (lhs: UserDTO, rhs: UserDTO) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
