//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

public class UpdateReviewRequest: APIModel {

    public enum State: String, Codable, Equatable, CaseIterable {
        case new = "NEW"
        case executed = "EXECUTED"
    }

    public var reviewId: ID?

    public var state: State?

    public init(reviewId: ID? = nil, state: State? = nil) {
        self.reviewId = reviewId
        self.state = state
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        reviewId = try container.decodeIfPresent("reviewId")
        state = try container.decodeIfPresent("state")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(reviewId, forKey: "reviewId")
        try container.encodeIfPresent(state, forKey: "state")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? UpdateReviewRequest else { return false }
      guard self.reviewId == object.reviewId else { return false }
      guard self.state == object.state else { return false }
      return true
    }

    public static func == (lhs: UpdateReviewRequest, rhs: UpdateReviewRequest) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
