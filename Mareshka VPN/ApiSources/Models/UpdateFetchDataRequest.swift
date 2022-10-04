//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

public class UpdateFetchDataRequest: APIModel {

    public var deviceId: String?

    public var downloaded: Int?

    public var uploaded: Int?

    public init(deviceId: String? = nil, downloaded: Int? = nil, uploaded: Int? = nil) {
        self.deviceId = deviceId
        self.downloaded = downloaded
        self.uploaded = uploaded
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        deviceId = try container.decodeIfPresent("deviceId")
        downloaded = try container.decodeIfPresent("downloaded")
        uploaded = try container.decodeIfPresent("uploaded")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        try container.encodeIfPresent(deviceId, forKey: "deviceId")
        try container.encodeIfPresent(downloaded, forKey: "downloaded")
        try container.encodeIfPresent(uploaded, forKey: "uploaded")
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? UpdateFetchDataRequest else { return false }
      guard self.deviceId == object.deviceId else { return false }
      guard self.downloaded == object.downloaded else { return false }
      guard self.uploaded == object.uploaded else { return false }
      return true
    }

    public static func == (lhs: UpdateFetchDataRequest, rhs: UpdateFetchDataRequest) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}