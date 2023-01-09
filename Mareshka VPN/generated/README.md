# MatreshkaAPI

This is an api generated from a OpenAPI 3.0 spec with [SwagGen](https://github.com/yonaskolb/SwagGen)

## Operation

Each operation lives under the `MatreshkaAPI` namespace and within an optional tag: `MatreshkaAPI(.tagName).operationId`. If an operation doesn't have an operationId one will be generated from the path and method.

Each operation has a nested `Request` and a `Response`, as well as a static `service` property

#### Service

This is the struct that contains the static information about an operation including it's id, tag, method, pre-modified path, and authorization requirements. It has a generic `ResponseType` type which maps to the `Response` type.
You shouldn't really need to interact with this service type.

#### Request

Each request is a subclass of `APIRequest` and has an `init` with a body param if it has a body, and a `options` struct for other url and path parameters. There is also a convenience init for passing parameters directly.
The `options` and `body` structs are both mutable so they can be modified before actually sending the request.

#### Response

The response is an enum of all the possible responses the request can return. it also contains getters for the `statusCode`, whether it was `successful`, and the actual decoded optional `success` response. If the operation only has one type of failure type there is also an optional `failure` type.

## Model
Models that are sent and returned from the API are mutable classes. Each model is `Equatable` and `Codable`.

`Required` properties are non optional and non-required are optional

All properties can be passed into the initializer, with `required` properties being mandatory.

If a model has `additionalProperties` it will have a subscript to access these by string

## APIClient
The `APIClient` is used to encode, authorize, send, monitor, and decode the requests. There is a `APIClient.default` that uses the default `baseURL` otherwise a custom one can be initialized:

```swift
public init(baseURL: String, sessionManager: SessionManager = .default, defaultHeaders: [String: String] = [:], behaviours: [RequestBehaviour] = [])
```

#### APIClient properties

- `baseURL`: The base url that every request `path` will be appended to
- `behaviours`: A list of [Request Behaviours](#requestbehaviour) to add to every request
- `sessionManager`: An `Alamofire.SessionManager` that can be customized
- `defaultHeaders`: Headers that will be applied to every request
- `decodingQueue`: The `DispatchQueue` to decode responses on

#### Making a request
To make a request first initialize a [Request](#request) and then pass it to `makeRequest`. The `complete` closure will be called with an `APIResponse`

```swift
func makeRequest<T>(_ request: APIRequest<T>, behaviours: [RequestBehaviour] = [], queue: DispatchQueue = DispatchQueue.main, complete: @escaping (APIResponse<T>) -> Void) -> Request? {
```

Example request (that is not neccessarily in this api):

```swift

let getUserRequest = MatreshkaAPI.User.GetUser.Request(id: 123)
let apiClient = APIClient.default

apiClient.makeRequest(getUserRequest) { apiResponse in
    switch apiResponse {
        case .result(let apiResponseValue):
        	if let user = apiResponseValue.success {
        		print("GetUser returned user \(user)")
        	} else {
        		print("GetUser returned \(apiResponseValue)")
        	}
        case .error(let apiError):
        	print("GetUser failed with \(apiError)")
    }
}
```

Each [Request](#request) also has a `makeRequest` convenience function that uses `MatreshkaAPI.shared`.

#### APIResponse
The `APIResponse` that gets passed to the completion closure contains the following properties:

- `request`: The original request
- `result`: A `Result` type either containing an `APIClientError` or the [Response](#response) of the request
- `urlRequest`: The `URLRequest` used to send the request
- `urlResponse`: The `HTTPURLResponse` that was returned by the request
- `data`: The `Data` returned by the request.
- `timeline`: The `Alamofire.Timeline` of the request which contains timing information.

#### Encoding and Decoding
Only JSON requests and responses are supported. These are encoded and decoded by `JSONEncoder` and `JSONDecoder` respectively, using Swift's `Codable` apis.
There are some options to control how invalid JSON is handled when decoding and these are available as static properties on `MatreshkaAPI`:

- `safeOptionalDecoding`: Whether to discard any errors when decoding optional properties. Defaults to `true`.
- `safeArrayDecoding`: Whether to remove invalid elements instead of throwing when decoding arrays. Defaults to `true`.

Dates are encoded and decoded differently according to the swagger date format. They use different `DateFormatter`'s that you can set.
- `date-time`
    - `DateTime.dateEncodingFormatter`: defaults to `yyyy-MM-dd'T'HH:mm:ss.Z`
    - `DateTime.dateDecodingFormatters`: an array of date formatters. The first one to decode successfully will be used
- `date`
    - `DateDay.dateFormatter`: defaults to `yyyy-MM-dd`

#### APIClientError
This is error enum that `APIResponse.result` may contain:

```swift
public enum APIClientError: Error {
    case unexpectedStatusCode(statusCode: Int, data: Data)
    case decodingError(DecodingError)
    case requestEncodingError(String)
    case validationError(String)
    case networkError(Error)
    case unknownError(Error)
}
```

#### RequestBehaviour
Request behaviours are used to modify, authorize, monitor or respond to requests. They can be added to the `APIClient.behaviours` for all requests, or they can passed into `makeRequest` for just that single request.

`RequestBehaviour` is a protocol you can conform to with each function being optional. As the behaviours must work across multiple different request types, they only have access to a typed erased `AnyRequest`.

```swift
public protocol RequestBehaviour {

    /// runs first and allows the requests to be modified. If modifying asynchronously use validate
    func modifyRequest(request: AnyRequest, urlRequest: URLRequest) -> URLRequest

    /// validates and modifies the request. complete must be called with either .success or .fail
    func validate(request: AnyRequest, urlRequest: URLRequest, complete: @escaping (RequestValidationResult) -> Void)

    /// called before request is sent
    func beforeSend(request: AnyRequest)

    /// called when request successfuly returns a 200 range response
    func onSuccess(request: AnyRequest, result: Any)

    /// called when request fails with an error. This will not be called if the request returns a known response even if the a status code is out of the 200 range
    func onFailure(request: AnyRequest, error: APIClientError)

    /// called if the request recieves a network response. This is not called if request fails validation or encoding
    func onResponse(request: AnyRequest, response: AnyResponse)
}
```

### Authorization
Each request has an optional `securityRequirement`. You can create a `RequestBehaviour` that checks this requirement and adds some form of authorization (usually via headers) in `validate` or `modifyRequest`. An alternative way is to set the `APIClient.defaultHeaders` which applies to all requests.

#### Reactive and Promises
To add support for a specific asynchronous library, just add an extension on `APIClient` and add a function that wraps the `makeRequest` function and converts from a closure based syntax to returning the object of choice (stream, future...ect)

## Models

- **AdminAuthRequest**
- **AdminDTO**
- **AnonymousUserDTO**
- **AppleAuthRequest**
- **AppleHookRequest**
- **ApplicationContext**
- **AttachTokenRequest**
- **AuthResponse**
- **AutowireCapableBeanFactory**
- **BeanFactory**
- **BuyByBalanceRequest**
- **BuySubRequest**
- **CleanDevicesRequest**
- **CleanDevicesResponse**
- **CreateFeatureTicketRequest**
- **CreateInfoScreenRequest**
- **CreateReviewRequest**
- **CreateServerRequest**
- **CreateTariffRequest**
- **CreateTicketRequest**
- **CreateTopicIdeaRequest**
- **CreateTopicRequest**
- **CreateUpdateLogRequest**
- **DashboardDataResponse**
- **EditMainPageAdRequest**
- **EditServerRequest**
- **EditSystemDataRequest**
- **EditTicketRequest**
- **EditTopicRequest**
- **EditUserRequest**
- **EditWithdrawRequest**
- **EmailAuthRequest**
- **EmailVerificationDTO**
- **Environment**
- **FeatureTicketDTO**
- **GiveSubRequest**
- **GiveUserPermanentRequest**
- **GoogleAuthRequest**
- **InfoScreenDTO**
- **InfoScreenViewStatisticItem**
- **InitAnonymousUserRequest**
- **PageRequestParams**
- **PageResponseAnonymousUserDTO**
- **PageResponseFeatureTicketDTO**
- **PageResponseInfoScreenDTO**
- **PageResponseReviewDTO**
- **PageResponseServerDTO**
- **PageResponseTicketDTO**
- **PageResponseTopicDTO**
- **PageResponseTopicIdeaDTO**
- **PageResponseUpdateLogDTO**
- **PageResponseUserDTO**
- **PageResponseWithdrawDTO**
- **QrAuthDTO**
- **RedirectView**
- **RefreshTokenRequest**
- **ResetReferralDataRequest**
- **ReviewDTO**
- **RobokassaProceedRequest**
- **RobokassaResultRequest**
- **SendPushToAllRequest**
- **SendPushToUserRequest**
- **SendPushToUsersRequest**
- **ServerDTO**
- **ServerLoadStatisticItem**
- **ServerLoadStatisticResponse**
- **ServerLoadStatisticServer**
- **ServiceErrorResponse**
- **StartEmailVerificationRequest**
- **SubmitEmailVerificationRequest**
- **SubmitQrAuthRequest**
- **SubscriptionDTO**
- **SubscriptionStatisticItem**
- **SubscriptionStatisticResponse**
- **SystemData**
- **TariffDTO**
- **TariffStatisticItem**
- **TicketDTO**
- **TopicDTO**
- **TopicIdeaDTO**
- **UpdateFetchDataRequest**
- **UpdateLogDTO**
- **UpdateReviewRequest**
- **UserDTO**
- **UserStatisticItem**
- **UserStatisticResponse**
- **UserTokenDTO**
- **ViewInfoScreenRequest**
- **WithdrawDTO**
- **WithdrawRequest**

## Requests

- **MatreshkaAPI.AbstractAPI**
	- **AdRedirect**: GET `/ad-redirect`
	- **GetOpenVpnProfile**: GET `/openvpn-profile/{profile}`
	- **GetSystemAdImage**: GET `/uploads/mainad.png`
	- **TestingCloudMessage**: GET `/testing/cloud/{token}`
- **MatreshkaAPI.AdminInfoScreenAPI**
	- **CreateInfoScreen**: POST `/api/v1/admin/info-screen/`
	- **GetInfoScreenById**: GET `/api/v1/admin/info-screen/{screenid}`
	- **GetInfoScreenStatistic**: GET `/api/v1/admin/info-screen/statistic`
	- **GetInfoScreens1**: GET `/api/v1/admin/info-screen/`
	- **RemoveInfoScreen**: DELETE `/api/v1/admin/info-screen/{screenid}`
- **MatreshkaAPI.AdminPushAPI**
	- **SendPushToAll**: POST `/api/v1/admin/push/all`
	- **SendPushToUser**: POST `/api/v1/admin/push/user`
	- **SendPushToUsers**: POST `/api/v1/admin/push/users`
- **MatreshkaAPI.AdminReviewAPI**
	- **GetReviewById**: GET `/api/v1/admin/review/{reviewid}`
	- **GetReviews**: GET `/api/v1/admin/review/`
	- **GetSystemAdImage2**: GET `/api/v1/admin/review/review-image/{filename}`
	- **RemoveReview**: DELETE `/api/v1/admin/review/{reviewid}`
	- **UpdateReview**: PATCH `/api/v1/admin/review/`
- **MatreshkaAPI.AdminServerAPI**
	- **CreateServer**: POST `/api/v1/admin/server/`
	- **EditServer**: PATCH `/api/v1/admin/server/`
	- **GetServerById**: GET `/api/v1/admin/server/{serverid}`
	- **GetServers1**: GET `/api/v1/admin/server/`
	- **RemoveServer**: DELETE `/api/v1/admin/server/{serverid}`
- **MatreshkaAPI.AdminStatisticAPI**
	- **ExportServerStatistic**: GET `/api/v1/admin/statistic/server/csv`
	- **ExportSubscriptionStatisticInCSV**: GET `/api/v1/admin/statistic/subscription/csv`
	- **ExportUserStatisticInCSV**: GET `/api/v1/admin/statistic/user/csv`
	- **GetDashboardStatistic**: GET `/api/v1/admin/statistic/dashboard`
	- **GetServerStatistic**: GET `/api/v1/admin/statistic/server`
	- **GetSubscriptionStatistic**: GET `/api/v1/admin/statistic/subscription`
	- **GetSubscriptionStatistic1**: GET `/api/v1/admin/statistic/subscription/second`
	- **GetUserStatistic**: GET `/api/v1/admin/statistic/user`
- **MatreshkaAPI.AdminSystemAPI**
	- **EditSystemData**: PATCH `/api/v1/admin/system/`
	- **GetTariffById**: PATCH `/api/v1/admin/system/ad`
- **MatreshkaAPI.AdminTariffAPI**
	- **CreateTariff1**: POST `/api/v1/admin/tariff/`
	- **GetTariffById2**: GET `/api/v1/admin/tariff/{tariffid}`
	- **GetTariffStatistic**: GET `/api/v1/admin/tariff/statistic`
	- **GetTariffs3**: GET `/api/v1/admin/tariff/`
	- **RemoveTariff**: DELETE `/api/v1/admin/tariff/{tariffid}`
- **MatreshkaAPI.AdminTariffAPIV2**
	- **CreateTariff**: POST `/api/v2/admin/tariff/`
	- **GetTariffById1**: GET `/api/v2/admin/tariff/{tariffid}`
	- **GetTariffs1**: GET `/api/v2/admin/tariff/`
- **MatreshkaAPI.AdminTicketAPI**
	- **EditTicket**: PATCH `/api/v1/admin/ticket/`
	- **GetNewTickets**: GET `/api/v1/admin/ticket/new-tickets`
	- **GetTicketById**: GET `/api/v1/admin/ticket/{ticketid}`
	- **GetTicketById1**: GET `/api/v1/admin/feature-ticket/{ticketid}`
	- **GetTickets**: GET `/api/v1/admin/ticket/`
	- **GetTickets1**: GET `/api/v1/admin/feature-ticket/`
	- **RemoveTicket**: DELETE `/api/v1/admin/ticket/{ticketid}`
	- **RemoveTicket1**: DELETE `/api/v1/admin/feature-ticket/{ticketid}`
- **MatreshkaAPI.AdminTopicAPI**
	- **CreateTopic**: POST `/api/v1/admin/topic/`
	- **CreateTopicIdea**: POST `/api/v1/topic/topic-idea`
	- **EditTopic**: PATCH `/api/v1/admin/topic/`
	- **FindTopics**: GET `/api/v1/topic/find`
	- **FindTopics1**: GET `/api/v1/admin/topic/find`
	- **GetTopicById**: GET `/api/v1/topic/{topicid}`
	- **GetTopicById1**: GET `/api/v1/admin/topic/{topicid}`
	- **GetTopicCategories**: GET `/api/v1/topic/topic-categories`
	- **GetTopicIdeas**: GET `/api/v1/admin/topic/topic-ideas`
	- **GetTopicLanguages**: GET `/api/v1/topic/topic-languages`
	- **GetTopicPlatforms**: GET `/api/v1/topic/topic-platforms`
	- **GetTopics**: GET `/api/v1/topic/`
	- **GetTopics1**: GET `/api/v1/admin/topic/`
	- **RemoveTopic**: DELETE `/api/v1/admin/topic/{topicid}`
- **MatreshkaAPI.AdminUpdateAPI**
	- **CreateUpdate**: POST `/api/v1/admin/update/`
	- **GetUpdateById**: GET `/api/v1/admin/update/{updateid}`
	- **GetUpdates1**: GET `/api/v1/admin/update/`
	- **RemoveUpdateLog**: DELETE `/api/v1/admin/update/{updateid}`
- **MatreshkaAPI.AdminUserAPI**
	- **EditUser**: PATCH `/api/v1/admin/user/`
	- **FindUsers**: GET `/api/v1/admin/user/find`
	- **GetAnonymousUser**: GET `/api/v1/admin/user/anonymous/{anonymoususerid}`
	- **GetAnonymousUsers**: GET `/api/v1/admin/user/anonymous`
	- **GetSubscription**: GET `/api/v1/admin/user/subscription/{userid}`
	- **GetUserById**: GET `/api/v1/admin/user/{userid}`
	- **GetUsers**: GET `/api/v1/admin/user/`
	- **GivePermanent**: PATCH `/api/v1/admin/user/give-permanent`
	- **GiveSub**: PATCH `/api/v1/admin/user/give-sub`
	- **RemoveAnonymousUser**: DELETE `/api/v1/admin/user/anonymous/{anonymoususerid}`
	- **RemovePermanent**: DELETE `/api/v1/admin/user/permanent/{userid}`
	- **RemoveSub**: DELETE `/api/v1/admin/user/remove-sub/{userid}`
	- **RemoveUser**: DELETE `/api/v1/admin/user/{userid}`
	- **ResetReferralData**: PATCH `/api/v1/admin/user/reset-referral`
- **MatreshkaAPI.AdminWithdrawAPI**
	- **EditWithdraw**: PATCH `/api/v1/admin/withdraw/`
	- **GetWithdraw**: GET `/api/v1/admin/withdraw/`
	- **GetWithdrawById**: GET `/api/v1/admin/withdraw/{withdrawid}`
	- **RemoveWithdraw**: DELETE `/api/v1/admin/withdraw/{withdrawid}`
- **MatreshkaAPI.AdminAPI**
	- **GetMe1**: GET `/api/v1/admin/me`
- **MatreshkaAPI.AppleAPI**
	- **BuySub**: POST `/api/v1/apple/buy`
	- **ReloadPurchase**: POST `/api/v1/apple/reload-purchase`
	- **WebHook**: POST `/api/v1/apple/hook`
- **MatreshkaAPI.AuthAPI**
	- **AdminAuth**: POST `/api/v1/auth/admin`
	- **AuthByApple**: POST `/api/v1/auth/apple`
	- **AuthByEmail**: POST `/api/v1/auth/email`
	- **AuthByGoogle**: POST `/api/v1/auth/google`
	- **GetQrImage**: GET `/api/v1/auth/qr/image/{id}`
	- **RefreshToken**: POST `/api/v1/auth/token/refresh`
	- **StartEmailVerification**: POST `/api/v1/auth/email-confirmation/start`
	- **StartQrAuth**: POST `/api/v1/auth/qr/start`
	- **SubmitEmailVerification**: POST `/api/v1/auth/email-confirmation/submit`
- **MatreshkaAPI.BillingAPI**
	- **CancelRobokassaSub**: POST `/api/v1/billing/robokassa/cancel`
	- **GeneratePaymentUrl1**: GET `/api/v1/billing/robokassa/payment-url`
	- **GetRobokassaInvoiceId**: GET `/api/v1/billing/robokassa/invoice-id`
	- **RobokassaFail**: POST `/api/v1/billing/robokassa/fail`
	- **RobokassaResult**: POST `/api/v1/billing/robokassa/result`
	- **RobokassaSuccess**: POST `/api/v1/billing/robokassa/success`
- **MatreshkaAPI.BillingAPIV2**
	- **GeneratePaymentUrl**: GET `/api/v2/billing/robokassa/payment-url`
- **MatreshkaAPI.InfoScreenAPI**
	- **GetInfoScreens**: GET `/api/v1/info-screen/`
	- **GetInfoScreensAnonymousUser**: GET `/api/v1/info-screen/anon/{deviceid}`
	- **ViewInfoScreen**: POST `/api/v1/info-screen/view`
- **MatreshkaAPI.ReviewAPI**
	- **CreateReview**: POST `/api/v1/review/`
- **MatreshkaAPI.ServerAPI**
	- **GetServers**: GET `/api/v1/server/`
	- **UpdateServerStatus**: GET `/api/v1/server/status`
	- **UpdateServerStatus1**: GET `/api/v1/server/server-data`
- **MatreshkaAPI.SubscriptionAPI**
	- **BuySubscriptionByBalance**: POST `/api/v1/subscription/buy-by-balance`
	- **GetMySubscription**: GET `/api/v1/subscription/`
- **MatreshkaAPI.SystemAPI**
	- **GetPromocodeDiscount**: GET `/api/v1/system/promocode-discount/{promocode}`
	- **GetSystemAdImage1**: GET `/api/v1/system/ad-image`
	- **GetSystemData**: GET `/api/v1/system/`
- **MatreshkaAPI.TariffAPI**
	- **GetBonusTariffs1**: GET `/api/v1/tariff/bonus`
	- **GetPaymentTariffs**: GET `/api/v1/tariff/payment`
	- **GetTariffs2**: GET `/api/v1/tariff/`
- **MatreshkaAPI.TariffAPIV2**
	- **GetBonusTariffs**: GET `/api/v2/tariff/bonus`
	- **GetTariffs**: GET `/api/v2/tariff/`
- **MatreshkaAPI.TicketAPI**
	- **CreateTicket**: POST `/api/v1/ticket/`
	- **CreateTicket1**: POST `/api/v1/feature-ticket/`
- **MatreshkaAPI.UpdateAPI**
	- **GetUpdates**: GET `/api/v1/update/`
- **MatreshkaAPI.UserAPI**
	- **AddTokenToUser**: POST `/api/v1/user/token`
	- **CleanDevices**: POST `/api/v1/user/clean-devices`
	- **CreateWithdraw**: POST `/api/v1/user/withdraw`
	- **ExistsByEmail**: GET `/api/v1/user/email-exists/{email}`
	- **GetMe**: GET `/api/v1/user/me`
	- **GetWithdraws**: GET `/api/v1/user/withdraw`
	- **InitAnonymous**: POST `/api/v1/user/anonymous`
	- **RemoveMe**: DELETE `/api/v1/user/`
	- **RemoveUserToken**: DELETE `/api/v1/user/token/{tokenid}`
	- **SubmitQrAuth**: POST `/api/v1/user/submit-qr-auth`
	- **UpdateFetchData**: PATCH `/api/v1/user/fetch-data`
