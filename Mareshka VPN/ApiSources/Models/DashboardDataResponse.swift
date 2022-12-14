//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

public class DashboardDataResponse: APIModel {

    public var serversCount: Int?

    public var usersByDay: Int?

    public var usersCount: Int?

    public init(serversCount: Int? = nil, usersByDay: Int? = nil, usersCount: Int? = nil) {
        self.serversCount = serversCount
        self.usersByDay = usersByDay
        self.usersCount = usersCount
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        serversCount = try container.decodeIfPresent("serversCount")
        usersByDay = try container.decodeIfPresent("usersByDay")
        usersCount = try container.decodeIfPresent("usersCount")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(serversCount, forKey: "serversCount")
        try container.encodeIfPresent(usersByDay, forKey: "usersByDay")
        try container.encodeIfPresent(usersCount, forKey: "usersCount")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? DashboardDataResponse else { return false }
      guard self.serversCount == object.serversCount else { return false }
      guard self.usersByDay == object.usersByDay else { return false }
      guard self.usersCount == object.usersCount else { return false }
      return true
    }

    public static func == (lhs: DashboardDataResponse, rhs: DashboardDataResponse) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
