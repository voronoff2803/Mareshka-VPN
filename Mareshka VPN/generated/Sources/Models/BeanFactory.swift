//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

public class BeanFactory: APIModel {

    public init() {
    }

    public required init(from decoder: Decoder) throws {
    }

    public func encode(to encoder: Encoder) throws {
    }

    public func isEqual(to object: Any?) -> Bool {
      guard object is BeanFactory else { return false }
      return true
    }

    public static func == (lhs: BeanFactory, rhs: BeanFactory) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
