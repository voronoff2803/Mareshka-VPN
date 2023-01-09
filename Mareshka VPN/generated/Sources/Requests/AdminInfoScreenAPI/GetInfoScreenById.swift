//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

extension MatreshkaAPI.AdminInfoScreenAPI {

    /** (Админ-метод) Получение экрана по ID */
    public enum GetInfoScreenById {

        public static let service = APIService<Response>(id: "getInfoScreenById", tag: "Admin - InfoScreen API", method: "GET", path: "/api/v1/admin/info-screen/{screenId}", hasBody: false, securityRequirements: [SecurityRequirement(type: "Bearer", scopes: [])])

        public final class Request: APIRequest<Response> {

            public struct Options {

                public var screenId: ID

                public init(screenId: ID) {
                    self.screenId = screenId
                }
            }

            public var options: Options

            public init(options: Options) {
                self.options = options
                super.init(service: GetInfoScreenById.service)
            }

            /// convenience initialiser so an Option doesn't have to be created
            public convenience init(screenId: ID) {
                let options = Options(screenId: screenId)
                self.init(options: options)
            }

            public override var path: String {
                return super.path.replacingOccurrences(of: "{" + "screenId" + "}", with: "\(self.options.screenId.encode())")
            }
        }

        public enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {
            public typealias SuccessType = InfoScreenDTO

            /** OK */
            case status200(InfoScreenDTO)

            public var success: InfoScreenDTO? {
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
                case 200: self = try .status200(decoder.decode(InfoScreenDTO.self, from: data))
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
