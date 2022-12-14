//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

extension MatreshkaAPI.BillingAPI {

    /** Сгенерировать Payment URL */
    public enum GeneratePaymentUrl1 {

        public static let service = APIService<Response>(id: "generatePaymentUrl_1", tag: "Billing API", method: "GET", path: "/api/v1/billing/robokassa/payment-url", hasBody: false, securityRequirements: [SecurityRequirement(type: "Bearer", scopes: [])])

        public final class Request: APIRequest<Response> {

            public struct Options {

                public var email: String

                public var promo: String?

                public var tariffId: ID

                public init(email: String, promo: String? = nil, tariffId: ID) {
                    self.email = email
                    self.promo = promo
                    self.tariffId = tariffId
                }
            }

            public var options: Options

            public init(options: Options) {
                self.options = options
                super.init(service: GeneratePaymentUrl1.service)
            }

            /// convenience initialiser so an Option doesn't have to be created
            public convenience init(email: String, promo: String? = nil, tariffId: ID) {
                let options = Options(email: email, promo: promo, tariffId: tariffId)
                self.init(options: options)
            }

            public override var queryParameters: [String: Any] {
                var params: [String: Any] = [:]
                params["email"] = options.email
                if let promo = options.promo {
                  params["promo"] = promo
                }
                params["tariffId"] = options.tariffId.encode()
                return params
            }
        }

        public enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {
            public typealias SuccessType = String

            /** OK */
            case status200(String)

            public var success: String? {
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
                case 200: self = try .status200(decoder.decode(String.self, from: data))
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
