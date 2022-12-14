//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

extension MatreshkaAPI.AdminInfoScreenAPI {

    /** (Админ-метод) Получение статистики */
    public enum GetInfoScreenStatistic {

        public static let service = APIService<Response>(id: "getInfoScreenStatistic", tag: "Admin - InfoScreen API", method: "GET", path: "/api/v1/admin/info-screen/statistic", hasBody: false, securityRequirements: [SecurityRequirement(type: "Bearer", scopes: [])])

        public final class Request: APIRequest<Response> {

            public struct Options {

                public var startDate: DateTime

                public var endDate: DateTime

                public var screenId: ID

                public init(startDate: DateTime, endDate: DateTime, screenId: ID) {
                    self.startDate = startDate
                    self.endDate = endDate
                    self.screenId = screenId
                }
            }

            public var options: Options

            public init(options: Options) {
                self.options = options
                super.init(service: GetInfoScreenStatistic.service)
            }

            /// convenience initialiser so an Option doesn't have to be created
            public convenience init(startDate: DateTime, endDate: DateTime, screenId: ID) {
                let options = Options(startDate: startDate, endDate: endDate, screenId: screenId)
                self.init(options: options)
            }

            public override var queryParameters: [String: Any] {
                var params: [String: Any] = [:]
                params["startDate"] = options.startDate.encode()
                params["endDate"] = options.endDate.encode()
                params["screenId"] = options.screenId.encode()
                return params
            }
        }

        public enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {
            public typealias SuccessType = [InfoScreenViewStatisticItem]

            /** OK */
            case status200([InfoScreenViewStatisticItem])

            public var success: [InfoScreenViewStatisticItem]? {
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
                case 200: self = try .status200(decoder.decode([InfoScreenViewStatisticItem].self, from: data))
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
