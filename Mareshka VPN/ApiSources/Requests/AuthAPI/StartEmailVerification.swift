//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

extension MatreshkaAPI.AuthAPI {

    /** Старт подтверждения по E-MAIL для авторизации */
    public enum StartEmailVerification {

        public static let service = APIService<Response>(id: "startEmailVerification", tag: "Auth API", method: "POST", path: "/api/v1/auth/email-confirmation/start", hasBody: true, securityRequirements: [])

        public final class Request: APIRequest<Response> {

            public var body: StartEmailVerificationRequest

            public init(body: StartEmailVerificationRequest, encoder: RequestEncoder? = nil) {
                self.body = body
                super.init(service: StartEmailVerification.service) { defaultEncoder in
                    return try (encoder ?? defaultEncoder).encode(body)
                }
            }
        }

        public enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {
            public typealias SuccessType = EmailVerificationDTO

            /** OK */
            case status200(EmailVerificationDTO)

            public var success: EmailVerificationDTO? {
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
                case 200: self = try .status200(decoder.decode(EmailVerificationDTO.self, from: data))
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
