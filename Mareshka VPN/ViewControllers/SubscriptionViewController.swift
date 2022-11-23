//
//  SubscriptionViewController.swift
//  Matreshka VPN
//
//  Created by Alexey Voronov on 04.04.2022.
//

import UIKit
import FloatingPanel
import BLTNBoard
import InAppPurchase
import FirebaseAnalytics

class SubscriptionViewController: RootViewController {
    
    @IBOutlet weak var referalActionView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    var tariffID = ""
    
    var bulletinManager: BLTNItemManager?
    
    var tariffs: [TariffDTO] = [] {
        didSet {
            updateUITariffs()
        }
    }
    
    var fpc: FloatingPanelController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Panel")
        
        fpc = FloatingPanelController()
        fpc.set(contentViewController: vc)
        fpc.layout = InformationLayout()
        fpc.surfaceView.backgroundColor = .secondarySystemBackground
        fpc.isRemovalInteractionEnabled = true

        // Do any additional setup after loading the view.
        
        setupReferalActionView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        MatreshkaHelper.shared.getTariffs() { tariff in
            if MatreshkaHelper.shared.systemGlobalConfig.appleModeration ?? false {
                self.tariffs = [TariffDTO(ballCost: 0, bonus: false, chPrice: 20.0, discount: nil, duration: 1, durationType: .month, enPrice: 0.99, id: UUID(), locale: nil, name: "1 Month", ruPrice: 99.0)]
            } else {
                self.tariffs = tariff
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
            if let scrollView = self?.scrollView {
                let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom)
                scrollView.setContentOffset(bottomOffset, animated: true)
            }
        }
    }
    
    
    @objc func appBecomeActive() {
        MatreshkaHelper.shared.loadProfile()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setupReferalActionView()
    }
    
    func setupReferalActionView() {
        self.referalActionView.isHidden = !(MatreshkaHelper.shared.systemGlobalConfig.enablePromos ?? false &&
                                            !MatreshkaHelper.shared.isAnonymousUser)
    }
    
    func updateUITariffs() {
        stackView.arrangedSubviews.forEach({if $0 is TariffView { $0.removeFromSuperview() }})
        tariffs.sorted(by: {$0.ballCost ?? 0 < $1.ballCost ?? 0}).forEach({tariff in
            let tariffView = TariffView()
            tariffView.delegate = self
            tariffView.setup(tariff: tariff)
            stackView.addArrangedSubview(tariffView)
        })
    }
    
    @objc func buySubscription() {
        if MatreshkaHelper.shared.isAnonymousUser {
            MatreshkaHelper.shared.loginIfNeed()
            return
        }
        if MatreshkaHelper.shared.systemGlobalConfig.appleModeration == true ||
            !MatreshkaHelper.shared.isRuRegion() {
            self.present(self.fpc, animated: true)
        } else if let url = URL(string: "\(MatreshkaHelper.webDomain)/?mobile_buy=true&buy_email=\(MatreshkaHelper.shared.user?.email ?? "")") {
            if MatreshkaHelper.shared.isAnonymousUser { MatreshkaHelper.shared.loginIfNeed(); return }
            if MatreshkaHelper.shared.subscription == nil { MatreshkaHelper.shared.isSubWaiting = true }
            UIApplication.shared.open(url)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @IBAction func termsOfUse() {
        guard let url = URL(string: MatreshkaHelper.webDomain + "/oferta") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func privacyPolicy() {
        guard let url = URL(string: MatreshkaHelper.webDomain + "/privacy") else { return }
        UIApplication.shared.open(url)
    }
    
    
    @IBAction func restorePurchases() {
        let iap = InAppPurchase.default
        SwiftLoader.show(animated: true)
        iap.restore(handler: { (result) in
            switch result {
            case .success(let response):
                if let url = Bundle.main.appStoreReceiptURL,
                   let data = try? Data(contentsOf: url) {
                    let receiptBase64 = data.base64EncodedString()
                    MatreshkaHelper.shared.sendReceipt(receipt: receiptBase64, completion: {})
                }
            case .failure(let error):
                MatreshkaHelper.shared.showAlert(message: error.localizedDescription, error: true)
            }
            
            SwiftLoader.hide()
        })
    }
    
    
    func cardPaymentAction(tariff: TariffDTO) {
        MatreshkaHelper.shared.getRobocassaURL(tariff: tariff)
        
        FirebaseAnalytics.Analytics.logEvent("begin_checkout", parameters: ["product_id": tariff.id?.uuidString ?? "",
                                                                           "product_name": tariff.name ?? "",
                                                                           "price": tariff.enPrice ?? "",
                                                                           "currency": "USD"])
    }
    
    func applePaymentAction(tariff: TariffDTO) {
        FirebaseAnalytics.Analytics.logEvent("begin_checkout", parameters: ["product_id": tariff.id?.uuidString ?? "",
                                                                            "payment_type": "apple_pay",
                                                                            "product_name": tariff.name ?? "",
                                                                            "price": tariff.enPrice ?? "",
                                                                            "currency": "USD"])
        
        if MatreshkaHelper.shared.systemGlobalConfig.appleModeration ?? false {
            MatreshkaHelper.shared.makeInAppSubscription(identifier: "premium") {
                MatreshkaHelper.shared.showAlert(message: "sucessBuy".localized, error: false)
                MatreshkaHelper.shared.loadProfile()
            }
            return
        }
        
        MatreshkaHelper.shared.makeInAppSubscription(identifier: String(tariff.id?.uuidString.suffix(12) ?? "").lowercased()) {
            FirebaseAnalytics.Analytics.logEvent("purchase", parameters: ["product_id": tariff.id?.uuidString ?? "",
                                                                          "payment_type": "apple_pay",
                                                                          "product_name": tariff.name ?? "",
                                                                          "price": tariff.enPrice ?? "",
                                                                          "currency": "USD"])
            
            MatreshkaHelper.shared.showAlert(message: "sucessBuy".localized, error: false)
            MatreshkaHelper.shared.loadProfile()
            self.bulletinManager?.dismissBulletin()
        }
    }
}


extension SubscriptionViewController: TariffViewDelegate {
    func tariffSelectAction(tariff: TariffDTO) {
        if MatreshkaHelper.shared.isAnonymousUser {
            MatreshkaHelper.shared.loginIfNeed()
            return
        }
        
        if MatreshkaHelper.shared.systemGlobalConfig.appleModeration == true {
            self.present(self.fpc, animated: true)
            bulletinManager?.dismissBulletin()
            return
        }
        
        if MatreshkaHelper.shared.subscription == nil { MatreshkaHelper.shared.isSubWaiting = true }
        
        let page = PaymentSelectBulletinPage(tariff: tariff)
        
        let rootItem: BLTNItem = page
        let manager = BLTNItemManager(rootItem: rootItem)
        manager.backgroundColor = #colorLiteral(red: 0.09678619355, green: 0.1317168474, blue: 0.2372510433, alpha: 1)
        
        page.appleHandler = {tariff in self.applePaymentAction(tariff: tariff)}
        page.qiwiHandler = {tariff in self.cardPaymentAction(tariff: tariff)}
        page.cardHandler = {tariff in self.cardPaymentAction(tariff: tariff)}
        
        bulletinManager = manager
        
        bulletinManager?.showBulletin(in: UIApplication.shared)
    }
}
