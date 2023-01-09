//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

extension MatreshkaAPI.AppleAPI {

    /** WebHook Apple */
    public enum WebHook {

        public static let service = APIService<Response>(id: "webHook", tag: "Apple API", method: "POST", path: "/api/v1/apple/hook", hasBody: true, securityRequirements: [SecurityRequirement(type: "Bearer", scopes: [])])

        public final class Request: APIRequest<Response> {

            public var body: AppleHookRequest

            public init(body: AppleHookRequest, encoder: RequestEncoder? = nil) {
                self.body = body
                super.init(service: WebHook.service) { defaultEncoder in
                    return try (encoder ?? defaultEncoder).encode(body)
                }
            }
        }

        public enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {
            public typealias SuccessType = Bool

            /** OK */
            case status200(Bool)

            public var success: Bool? {
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
                case 200: self = try .status200(decoder.decode(Bool.self, from: data))
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
