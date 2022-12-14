//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

extension MatreshkaAPI.AdminSystemAPI {

    /** (Админ-метод) Изменение системных данных */
    public enum EditSystemData {

        public static let service = APIService<Response>(id: "editSystemData", tag: "Admin - System API", method: "PATCH", path: "/api/v1/admin/system/", hasBody: true, securityRequirements: [SecurityRequirement(type: "Bearer", scopes: [])])

        public final class Request: APIRequest<Response> {

            public var body: EditSystemDataRequest

            public init(body: EditSystemDataRequest, encoder: RequestEncoder? = nil) {
                self.body = body
                super.init(service: EditSystemData.service) { defaultEncoder in
                    return try (encoder ?? defaultEncoder).encode(body)
                }
            }
        }

        public enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {
            public typealias SuccessType = SystemData

            /** OK */
            case status200(SystemData)

            public var success: SystemData? {
                switch self {
                case .status200(let response): return response
                }
            }

            public var response: Any {
                switch self {
                case .status200(let response): return response
                }
            }

            public var statusCode: Int {
                switch self {
                case .status200: return 200
                }
            }

            public var successful: Bool {
                switch self {
                case .status200: return true
                }
            }

            public init(statusCode: Int, data: Data, decoder: ResponseDecoder) throws {
                switch statusCode {
                case 200: self = try .status200(decoder.decode(SystemData.self, from: data))
                default: throw APIClientError.unexpectedStatusCode(statusCode: statusCode, data: data)
                }
            }

            public var description: String {
                return "\(statusCode) \(successful ? "success" : "failure")"
            }

            public var debugDescription: String {
                var string = description
                let responseString = "\(response)"
                if responseString != "()" {
                    string += "\n\(responseString)"
                }
                return string
            }
        }
    }
}
