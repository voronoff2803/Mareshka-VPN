//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

public class DashboardDataResponse: APIModel {

    public var activeUsers: Int?

    public var anonymousCreatedUsersCount: Int?

    public var anonymousNotCreatedUsersCount: Int?

    public var anonymousUsersCount: Int?

    public var serversCount: Int?

    public var usersByDay: Int?

    public var usersCount: Int?

    public var usersWithSubscriptions: Int?

    public init(activeUsers: Int? = nil, anonymousCreatedUsersCount: Int? = nil, anonymousNotCreatedUsersCount: Int? = nil, anonymousUsersCount: Int? = nil, serversCount: Int? = nil, usersByDay: Int? = nil, usersCount: Int? = nil, usersWithSubscriptions: Int? = nil) {
        self.activeUsers = activeUsers
        self.anonymousCreatedUsersCount = anonymousCreatedUsersCount
        self.anonymousNotCreatedUsersCount = anonymousNotCreatedUsersCount
        self.anonymousUsersCount = anonymousUsersCount
        self.serversCount = serversCount
        self.usersByDay = usersByDay
        self.usersCount = usersCount
        self.usersWithSubscriptions = usersWithSubscriptions
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        activeUsers = try container.decodeIfPresent("activeUsers")
        anonymousCreatedUsersCount = try container.decodeIfPresent("anonymousCreatedUsersCount")
        anonymousNotCreatedUsersCount = try container.decodeIfPresent("anonymousNotCreatedUsersCount")
        anonymousUsersCount = try container.decodeIfPresent("anonymousUsersCount")
        serversCount = try container.decodeIfPresent("serversCount")
        usersByDay = try container.decodeIfPresent("usersByDay")
        usersCount = try container.decodeIfPresent("usersCount")
        usersWithSubscriptions = try container.decodeIfPresent("usersWithSubscriptions")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(activeUsers, forKey: "activeUsers")
        try container.encodeIfPresent(anonymousCreatedUsersCount, forKey: "anonymousCreatedUsersCount")
        try container.encodeIfPresent(anonymousNotCreatedUsersCount, forKey: "anonymousNotCreatedUsersCount")
        try container.encodeIfPresent(anonymousUsersCount, forKey: "anonymousUsersCount")
        try container.encodeIfPresent(serversCount, forKey: "serversCount")
        try container.encodeIfPresent(usersByDay, forKey: "usersByDay")
        try container.encodeIfPresent(usersCount, forKey: "usersCount")
        try container.encodeIfPresent(usersWithSubscriptions, forKey: "usersWithSubscriptions")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? DashboardDataResponse else { return false }
      guard self.activeUsers == object.activeUsers else { return false }
      guard self.anonymousCreatedUsersCount == object.anonymousCreatedUsersCount else { return false }
      guard self.anonymousNotCreatedUsersCount == object.anonymousNotCreatedUsersCount else { return false }
      guard self.anonymousUsersCount == object.anonymousUsersCount else { return false }
      guard self.serversCount == object.serversCount else { return false }
      guard self.usersByDay == object.usersByDay else { return false }
      guard self.usersCount == object.usersCount else { return false }
      guard self.usersWithSubscriptions == object.usersWithSubscriptions else { return false }
      return true
    }

    public static func == (lhs: DashboardDataResponse, rhs: DashboardDataResponse) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
