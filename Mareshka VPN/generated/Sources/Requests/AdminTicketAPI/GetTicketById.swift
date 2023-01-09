//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

extension MatreshkaAPI.AdminTicketAPI {

    /** (Админ-метод) Получение тикета по ID */
    public enum GetTicketById {

        public static let service = APIService<Response>(id: "getTicketById", tag: "Admin - Ticket API", method: "GET", path: "/api/v1/admin/ticket/{ticketId}", hasBody: false, securityRequirements: [SecurityRequirement(type: "Bearer", scopes: [])])

        public final class Request: APIRequest<Response> {

            public struct Options {

                public var ticketId: ID

                public init(ticketId: ID) {
                    self.ticketId = ticketId
                }
            }

            public var options: Options

            public init(options: Options) {
                self.options = options
                super.init(service: GetTicketById.service)
            }

            /// convenience initialiser so an Option doesn't have to be created
            public convenience init(ticketId: ID) {
                let options = Options(ticketId: ticketId)
                self.init(options: options)
            }

            public override var path: String {
                return super.path.replacingOccurrences(of: "{" + "ticketId" + "}", with: "\(self.options.ticketId.encode())")
            }
        }

        public enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {
            public typealias SuccessType = TicketDTO

            /** OK */
            case status200(TicketDTO)

            public var success: TicketDTO? {
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
                case 200: self = try .status200(decoder.decode(TicketDTO.self, from: data))
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
