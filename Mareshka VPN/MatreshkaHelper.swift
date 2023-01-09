//
//  MatreshkaHelper.swift
//  Mareshka VPN (new)
//
//  Created by Alexey Voronov on 19.06.2022.
//

import UIKit
import InAppPurchase
import SPIndicator
import SwiftyPing
import FirebaseAnalytics


class MatreshkaHelper {
    static let shared = MatreshkaHelper()
    
    var splashPresenter: SplashPresenterDescription? = SplashPresenter()
    
    static let domain = "https://new.matreshkavpn.com"
    static let webDomain = "https://matreshkavpn.com"
    static let googleClientID = "250829852194-k3slpecs1tnk3ssqe4mirjjs2enhpghf.apps.googleusercontent.com"
    let iap = InAppPurchase.default
    let vpnManager = WWVPNManager.shared
    var timer: Timer!
    weak var tabBarVC: TabViewController?
    var isSubWaiting = false
    
    var currentPromocode: String?
    
    var serversList: [ServerDTO] = [] {
        didSet {
            DispatchQueue.main.async {
                self.serversList.forEach({$0.updatePing {
                    if self.serversList.filter({$0.ping == nil}).isEmpty {
                        self.setSelectedServerIfNeedAndNotificate()
                    }
                }})
            }
        }
    }
    var systemGlobalConfig: SystemData = SystemData()
    
    init() {
        splashPresenter?.present()
        
        DispatchQueue.main.async { self.setup() }
    }
    
    var isFinishing = false
    
    func finishInitiation() {
        if isFinishing { return }
        isFinishing = true
        self.splashPresenter?.dismiss(completion: { [weak self] in
            self?.splashPresenter = nil
        })
    }
    
    func timerAction() {
        if serversList.isEmpty {
            setup()
        } else {
            timer.invalidate()
        }
    }
    
    func showAlert(message: String, error: Bool) {
//        #if targetEnvironment(macCatalyst)
//        let bundleFileName = "MacPlugin.bundle"
//        guard let bundleURL = Bundle.main.builtInPlugInsURL?
//            .appendingPathComponent(bundleFileName) else { return }
//        guard let bundle = Bundle(url: bundleURL) else { return }
//
//        guard let pluginClass = bundle.principalClass as? Plugin.Type else { return }
//
//        let plugin = pluginClass.init()
//        plugin.sayHello()
//
//        #else
//
        let alertVC = UIAlertController(title: error ? "error".localized : nil, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
        DispatchQueue.main.async {
            alertVC.show()
        }
        
//        #endif
    }
    
    func getSelectedServer() -> ServerDTO? {
        let serverId = MatreshkaHelper.shared.selectedServerId
        let server = MatreshkaHelper.shared.serversList.first(where: {$0.id?.description == serverId})
        return server
    }
    
    func isSubscriptionActive() -> Bool {
        var result = false
        if let expireDate = anonymousUser?.createdAt?.adding(days: 3) {
            if expireDate > Date() {
                result = true
            }
        }
        if let expireDate = user?.createdAt?.adding(days: 3) {
            if expireDate > Date() {
                result = true
            }
        }
        if let expireDate = subscription?.expiredAt {
            if expireDate > Date() {
                result = true
            }
        }
        return result
    }
    
    func setup() {
        updateSystemConfig()
        authAnonymousIfNoToken()
        loadServers()
        loadProfile()
        
        iap.addTransactionObserver(fallbackHandler: { result in
            switch result {
            case .success(let response):
                print(response)
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
    
    deinit {
        iap.removeTransactionObserver()
    }
    
    let api = APIClient.default
    var user: UserDTO? {
        didSet {
            FirebaseAnalytics.Analytics.setUserID(user?.id?.uuidString)
            NotificationCenter.default.post(name: .userProfileUpdate, object: nil)
        }
    }
    var anonymousUser: AnonymousUserDTO? {
        didSet {
            NotificationCenter.default.post(name: .userProfileUpdate, object: nil)
        }
    }
    var subscription: SubscriptionDTO? {
        didSet {
            NotificationCenter.default.post(name: .userProfileUpdate, object: nil)
        }
    }
    
    var isAnonymousUser: Bool {
        (anonymousUser != nil && user == nil)
    }
    
    var accessToken: String {
        get {
            return UserDefaults.standard.string(forKey: "access_token") ?? ""
        }
        set {
            if newValue != UserDefaults.standard.string(forKey: "access_token") ?? "" {
                UserDefaults.standard.set(newValue, forKey: "access_token")
                loadProfile()
                loadServers()
            }
        }
    }
    
    var refreshToken: String {
        get {
            return UserDefaults.standard.string(forKey: "refresh_token") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "refresh_token")
        }
    }
    
    var selectedServerId: String {
        get {
            return UserDefaults.standard.string(forKey: "selected_server") ?? ""
        }
        set {
            let oldVal = UserDefaults.standard.string(forKey: "selected_server") ?? ""
            UserDefaults.standard.set(newValue, forKey: "selected_server")
            print("==========")
            print(newValue, oldVal)
            if newValue != oldVal {
                NotificationCenter.default.post(name: .selectedServerUpdate, object: false)
            }
        }
    }
    
    func setSelectedServerIfNeedAndNotificate() {
        print(#function)
        
        if selectedServerId == "" {
            selectedServerId = serversList.min(by: {$0.ping! < $1.ping!})?.id?.description ?? ""
        } else {
            NotificationCenter.default.post(name: .selectedServerUpdate, object: true)
        }
        
        finishInitiation()
    }
    
    func isRuRegion() -> Bool {
        return Locale.current.regionCode?.contains("RU") ?? false
    }
    
    func registerForPushNotifications() {
        let application = UIApplication.shared
        
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
          )
        } else {
          let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {(accepted, error) in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                guard settings.authorizationStatus == .authorized else { return }
                DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
            }
        }
    }
    
    func authAnonymousIfNoToken() {
        if anonymousUser != nil { return }
        if accessToken != "" { return }
        
        let deviceId = getUUID() ?? UIDevice.current.identifierForVendor?.uuidString ?? ""
        api.makeRequest(MatreshkaAPI.UserAPI.InitAnonymous.Request(body: InitAnonymousUserRequest(deviceId: deviceId))) { response in
            switch response.result {
            case .success(let result):
                self.anonymousUser = result.success
                self.loadSubscription()
            case .failure(let error):
                self.showError(error: error, data: response.data)
                SwiftLoader.hide()
            }
        }
    }
    
    
    func authApple(credentials: String, email: String, authorizationCode: String) {
        let deviceId = getUUID() ?? UIDevice.current.identifierForVendor?.uuidString ?? ""
        SwiftLoader.show(animated: true)
        api.makeRequest(MatreshkaAPI.AuthAPI.AuthByApple.Request(body: AppleAuthRequest(credentials: credentials, deviceId: deviceId, email: email, authorizationCode: authorizationCode))) { response in
            SwiftLoader.hide()
            switch response.result {
            case .success(let result):
                self.accessToken = result.success?.token ?? ""
                self.refreshToken = result.success?.refreshToken ?? ""
                
                FirebaseAnalytics.Analytics.logEvent("registrationfinish", parameters: ["type": "apple"])
            case .failure(let error):
                self.showError(error: error, data: response.data)
            }
        }
    }
    
    func authGoogle(credentials: String, email: String) {
        let deviceId = getUUID() ?? UIDevice.current.identifierForVendor?.uuidString ?? ""
        SwiftLoader.show(animated: true)
        api.makeRequest(MatreshkaAPI.AuthAPI.AuthByGoogle.Request(body: GoogleAuthRequest(credentials: credentials, deviceId: deviceId, email: email))) { response in
            switch response.result {
            case .success(let result):
                self.accessToken = result.success?.token ?? ""
                self.refreshToken = result.success?.refreshToken ?? ""
                
                FirebaseAnalytics.Analytics.logEvent("registrationfinish", parameters: ["type": "google"])
            case .failure(let error):
                self.showError(error: error, data: response.data)
            }
            SwiftLoader.hide()
        }
        
    }
    
    var verificationId: ID?
    
    func authMailStart(email: String, completion: @escaping (_ error: APIClientError?) -> ()) {
        api.makeRequest(MatreshkaAPI.AuthAPI.StartEmailVerification.Request(body: StartEmailVerificationRequest(email: email.lowercased()))) { response in
            switch response.result {
            case .success(let result):
                self.verificationId = result.success?.id
                completion(nil)
            case .failure(let error):
                completion(error)
                self.showError(error: error, data: response.data)
            }
        }
    }
    
    
    func authMailSubmit(code: String, completion: @escaping () -> ()) {
        guard let verificationId = verificationId else { return }
        api.makeRequest(MatreshkaAPI.AuthAPI.SubmitEmailVerification.Request(body: SubmitEmailVerificationRequest(code: code, verificationId: verificationId))) { response in
            switch response.result {
            case .success(_):
                completion()
                self.authMail()
            case .failure(let error):
                self.showError(error: error, data: response.data)
            }
        }
    }
    
    func authMail() {
        guard let verificationId = verificationId else { return }
        let deviceId = getUUID() ?? UIDevice.current.identifierForVendor?.uuidString ?? ""
        SwiftLoader.show(animated: true)
        api.makeRequest(MatreshkaAPI.AuthAPI.AuthByEmail.Request(body: EmailAuthRequest(deviceId: deviceId, verificationId: verificationId))) { response in
            switch response.result {
            case .success(let result):
                self.accessToken = result.success?.token ?? ""
                self.refreshToken = result.success?.refreshToken ?? ""
                
                FirebaseAnalytics.Analytics.logEvent("registrationfinish", parameters: ["type": "google"])
            case .failure(let error):
                self.showError(error: error, data: response.data)
            }
            SwiftLoader.hide()
        }
    }
    
    
    func loadProfile() {
        //SwiftLoader.show(animated: true)
        MatreshkaHelper.shared.api.makeRequest(MatreshkaAPI.UserAPI.GetMe.Request()) { response in
            switch response.result {
            case .success(let resultProfile):
                self.user = resultProfile.success
                if self.user != nil {
                    self.registerForPushNotifications()
                }
                self.loadSubscription()
                self.sendDataUsage()
            case .failure(let error):
                if [403, 401].contains(response.urlResponse?.statusCode) && !self.isAnonymousUser {
                    if self.refreshToken == "" {
                        self.logout()
                    }
                }
            }
        }
    }
    
    func updateSystemConfig() {
        api.makeRequest(MatreshkaAPI.SystemAPI.GetSystemData.Request()) { response in
            switch response.result {
            case .success(let result):
                guard let success = result.success else { break }
                self.systemGlobalConfig = success
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func loadSubscription() {
        MatreshkaHelper.shared.api.makeRequest(MatreshkaAPI.SubscriptionAPI.GetMySubscription.Request()) { response in
            SwiftLoader.hide()
            switch response.result {
            case .success(let result):
                self.subscription = result.success
                if self.isSubWaiting {
                    self.tabBarVC?.selectedIndex = 2
                    self.showAlert(message: "sucessBuy".localized, error: false)
                    self.isSubWaiting = false
                }
            case .failure(_):
                if response.urlResponse?.statusCode == 404 {
                    self.subscription = nil
                }
            }
        }
    }
    
    func logout() {
        self.user = nil
        self.anonymousUser = nil
        self.accessToken = ""
        self.refreshToken = ""
        
        SwiftLoader.show(animated: true)
        self.authAnonymousIfNoToken()
        
        FirebaseAnalytics.Analytics.logEvent("log_out", parameters: nil)
    }
    
    func loadServers() {
        print("loadServers")
        
        MatreshkaHelper.shared.api.makeRequest(MatreshkaAPI.ServerAPI.GetServers.Request()) { response in
            switch response.result {
            case .success(let result):
                self.serversList = result.success ?? self.serversList
            case .failure(let error):
                self.serversList = { self.serversList }()
                print(error.description)
            }
        }
    }
    
    func makeInAppSubscription(identifier: String?, completion: @escaping () -> ()) {
        SwiftLoader.show(animated: true)
        
        iap.purchase(productIdentifier: identifier ?? "premium") { result in
            // This handler is called if the payment purchased, restored, deferred or failed.
            
            switch result {
            case .success(let response):
                if let url = Bundle.main.appStoreReceiptURL,
                   let data = try? Data(contentsOf: url) {
                    let receiptBase64 = data.base64EncodedString()
                    self.sendReceipt(receipt: receiptBase64, completion: completion)
                } else {
                    SwiftLoader.hide()
                }
            case .failure(let error):
                self.showAlert(message: error.localizedDescription, error: true)
                SwiftLoader.hide()
                
                FirebaseAnalytics.Analytics.logEvent("purchase_failed", parameters: ["reason": error.localizedDescription])
            }
        }
    }
    
    func sendReceipt(receipt: String, completion: @escaping () -> ()) {
        api.makeRequest(MatreshkaAPI.AppleAPI.BuySub.Request(body: BuySubRequest(receipt: receipt))) { response in
            // This handler is called if the payment purchased, restored, deferred or failed.
            switch response.result {
            case .success(let response):
                self.showAlert(message: "sucessBuy".localized, error: false)
                self.loadProfile()
                completion()
            case .failure(let error):
                self.showError(error: error, data: response.data)
            }
            
            SwiftLoader.hide()
        }
    }
    
    func getBonusTariffs(completion: @escaping ([TariffDTO]) -> ()) {
        api.makeRequest(MatreshkaAPI.TariffAPIV2.GetBonusTariffs.Request()) { response in
            switch response.result {
            case .success(let response):
                completion(response.success ?? [])
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func getTariffs(completion: @escaping ([TariffDTO]) -> ()) {
        api.makeRequest(MatreshkaAPI.TariffAPIV2.GetTariffs.Request()) { response in
            switch response.result {
            case .success(let response):
                completion(response.success ?? [])
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func getTickets(completion: @escaping ([WithdrawDTO]) -> ()) {
        api.makeRequest(MatreshkaAPI.UserAPI.GetWithdraws.Request(options: .init(params: PageRequestParams(page: 0, pageSize: 100)))) { response in
            switch response.result {
            case .success(let response):
                completion(response.success?.data ?? [])
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func buySubscriptionScore(id: String, completion: @escaping (SubscriptionDTO?) -> ()) {
        SwiftLoader.show(animated: true)
        api.makeRequest(MatreshkaAPI.SubscriptionAPI.BuySubscriptionByBalance.Request(body: BuyByBalanceRequest(tariffId: ID(uuidString: id)!))) { response in
            switch response.result {
            case .success(let response):
                completion(response.success)
            case .failure(let error):
                self.showError(error: error, data: response.data)
            }
            SwiftLoader.hide()
        }
    }
    
    func sendTicket(content: String?, email: String?, name: String?, completion: @escaping (TicketDTO?) -> ()) {
        api.makeRequest(MatreshkaAPI.TicketAPI.CreateTicket.Request(body: CreateTicketRequest(content: content, email: email, name: name))) { response in
            switch response.result {
            case .success(let response):
                completion(response.success)
            case .failure(let error):
                self.showError(error: error, data: response.data)
            }
        }
    }
    
    func sendToken(token: String) {
        print("apns token: \(token)")
        api.makeRequest(MatreshkaAPI.UserAPI.AddTokenToUser.Request(body: AttachTokenRequest(token: token))) { response in
            print(response)
        }
    }
    
    func cancelSub() {
        SwiftLoader.show(animated: true)
        api.makeRequest(MatreshkaAPI.BillingAPI.CancelRobokassaSub.Request()) { response in
            switch response.result {
            case .success( _):
                self.showAlert(message: "successSubCancel".localized, error: false)
            case .failure(let error):
                self.showError(error: error, data: response.data)
            }
            SwiftLoader.hide()
        }
    }
    
    func eraseAcc() {
        SwiftLoader.show(animated: true)
        let deviceId = getUUID() ?? UIDevice.current.identifierForVendor?.uuidString ?? ""
        api.makeRequest(MatreshkaAPI.UserAPI.CleanDevices.Request(body: CleanDevicesRequest(nowDeviceId: deviceId))){ response in
            switch response.result {
            case .success( _):
                break
            case .failure(let error):
                self.showError(error: error, data: response.data)
            }
            SwiftLoader.hide()
        }
    }
    
    
    
    func sendWithdraw(card: String?, count: Double?, email: String?, completion: @escaping (WithdrawDTO?) -> ()) {
        SwiftLoader.show(animated: true)
        api.makeRequest(MatreshkaAPI.UserAPI.CreateWithdraw.Request(body: WithdrawRequest(card: card, count: count, email: email))) { response in
            switch response.result {
            case .success(let response):
                completion(response.success)
                self.showAlert(message: "withdrawRequestSuccess".localized, error: false)
            case .failure(let error):
                self.showError(error: error, data: response.data)
            }
            SwiftLoader.hide()
        }
    }
    
    func removeAccount() {
        SwiftLoader.show(animated: true)
        api.makeRequest(MatreshkaAPI.UserAPI.RemoveMe.Request())  { response in
            switch response.result {
            case .success(_):
                self.logout()
            case .failure(let error):
                self.showError(error: error, data: response.data)
            }
            SwiftLoader.hide()
        }
        
        FirebaseAnalytics.Analytics.logEvent("delete_account", parameters: nil)
    }
    
    func getRobocassaURL(tariff: TariffDTO) {
        SwiftLoader.show(animated: true)
        api.makeRequest(MatreshkaAPI.BillingAPIV2.GeneratePaymentUrl.Request(email: user?.email ?? "", promo: self.currentPromocode, tariffId: tariff.id ?? UUID()))  { response in
            switch response.result {
            case .success(let res):
                // Wrong server answer
                break
            case .failure(let error):
                if let data = response.data {
                    if let url = URL(string: (String(data: data, encoding: .utf8)) ?? "") {
                        UIApplication.shared.open(url)
                    } else {
                        self.showError(error: error, data: response.data)
                    }
                } else {
                    self.showError(error: error, data: response.data)
                }
            }
            SwiftLoader.hide()
        }
    }
    
    
    func submitQR(qrData: String) {
        SwiftLoader.show(animated: true)
        api.makeRequest(MatreshkaAPI.UserAPI.SubmitQrAuth.Request(body: SubmitQrAuthRequest(qrAuthId: UUID(uuidString: qrData))))  { response in
            SwiftLoader.hide()
            switch response.result {
            case .success(let res):
                break
            case .failure(let error):
                if error.description == "Network error: Response could not be serialized, input data was nil or zero length." {
                    return
                }
                self.showError(error: error, data: response.data)
            }
            SwiftLoader.hide()
        }
    }
    
    func getInfoScreens(completion: @escaping ([InfoScreenDTO]) -> ()) {
        if isAnonymousUser {
            let deviceId = getUUID() ?? UIDevice.current.identifierForVendor?.uuidString ?? ""
            api.makeRequest(MatreshkaAPI.InfoScreenAPI.GetInfoScreensAnonymousUser.Request(deviceId: deviceId)) { response in
                switch response.result {
                case .success(let res):
                    completion(res.success ?? [])
                case .failure(let error):
                    self.showError(error: error, data: response.data)
                }
            }
        } else {
            api.makeRequest(MatreshkaAPI.InfoScreenAPI.GetInfoScreens.Request()) { response in
                switch response.result {
                case .success(let res):
                    print(res)
                    completion(res.success ?? [])
                case .failure(let error):
                    self.showError(error: error, data: response.data)
                }
            }
        }
    }
    
    func showError(error: APIClientError, data: Data?) {
        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any],
              let errorMessage = json["error"] as? String
        else { self.showAlert(message: error.description, error: true); return }
        
        self.showAlert(message: errorMessage, error: true)
    }
    
    func sendDataUsage(_ force: Bool = false) {
        if (!force && WWVPNManager.shared.status != .connected) { return }
        
        guard let p_upload = UserDefaults.standard.value(forKey: "p_upload") as? UInt64,
              let p_download = UserDefaults.standard.value(forKey: "p_download") as? UInt64
        else { return }
                
        let upload = SystemDataUsage.upload &- p_upload
        let download = SystemDataUsage.download &- p_download
        
        api.makeRequest(MatreshkaAPI.UserAPI.UpdateFetchData.Request(body: UpdateFetchDataRequest(deviceId: isAnonymousUser ? nil : getUUID(), downloaded: Int(download), uploaded: Int(upload)))) { response in
            switch response.result {
            case .success( _):
                break
            case .failure(let error):
                print(error.description)
            }
        }
    }
    
    func loginIfNeed() {
        guard let tabBarVC = tabBarVC,
              let profileVC = tabBarVC.viewControllers?[2] as? ProfileViewController,
              isAnonymousUser
        else {
            return
        }
        
        tabBarVC.selectedIndex = 2
        profileVC.buttonAction()
    }
    
    func connectVPN() {
        guard let selectedServer = getSelectedServer() else { return }
        
        guard let identifier = isAnonymousUser ? getUUID() : user?.email,
              let adress = selectedServer.address
        else {
            self.showAlert(message: "loginIfNeed mehod error", error: true)
            return
        }

        let config = Configuration(server: adress, account: identifier, password: identifier)
        
        FirebaseAnalytics.Analytics.logEvent("start_vpn", parameters: ["vpn_country": selectedServer.country ?? ""])
        
        vpnManager.connectIKEv2(config: config) { error in
            FirebaseAnalytics.Analytics.logEvent("vpn_failed", parameters: ["reason": error.localized])
            
            self.showAlert(message: error, error: true)
        }
    }
    
    func disconnectVPN(completionHandler: (()->Void)? = nil) {
        FirebaseAnalytics.Analytics.logEvent("stop_vpn", parameters: nil)
        
        vpnManager.disconnect(completionHandler: completionHandler)
    }
    
    func getUUID() -> String? {
        
        // create a keychain helper instance
        let keychain = KeychainAccess()
        
        // this is the key we'll use to store the uuid in the keychain
        let uuidKey = "com.horsltd.Matreshka.unique_uuid"
        
        // check if we already have a uuid stored, if so return it
        if let uuid = try? keychain.queryKeychainData(itemKey: uuidKey), uuid != nil {
            return uuid
        }
        
        // generate a new id
        guard let newId = UIDevice.current.identifierForVendor?.uuidString else {
            return nil
        }
        
        // store new identifier in keychain
        try? keychain.addKeychainData(itemKey: uuidKey, itemValue: newId)
        
        // return new id
        return newId
    }
}


extension ServerDTO {
    func updatePing(completion: @escaping () -> ()) {
        do {
            let once = try SwiftyPing(host: self.address ?? "", configuration: PingConfiguration(interval: 1.0, with: 2), queue: DispatchQueue.global())
            once.observer = { [weak self] response in
                if response.duration.millisecond < 2 {
                    self?.ping = 10000
                    completion()
                } else {
                    self?.ping = Double(response.duration.millisecond)
                    completion()
                }
            }
            once.targetCount = 1
            try once.startPinging()
        }
        catch {
            print(error.localizedDescription)
            self.ping = 10000
            completion()
        }
    }
}
