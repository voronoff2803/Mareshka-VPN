//
//  SubscriptionViewController.swift
//  Private Relay VPN
//
//  Created by Alexey Voronov on 19.05.2022.
//

import UIKit
import InAppPurchase

class PanelSubscriptionViewController: UIViewController {
    @IBOutlet weak var priceLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let iap = InAppPurchase.default
        iap.fetchProduct(productIdentifiers: ["premium"], handler: { (result) in
            switch result {
            case .success(let products):
                if let product = products.first {
                    let formatter = NumberFormatter()
                    formatter.maximumFractionDigits = 2
                    formatter.minimumFractionDigits = 0
                    formatter.currencyCode = Locale.current.currencyCode
                    formatter.numberStyle = .currency
                    
                    self.priceLabel.text = "/Week after".localized(formatter.string(for: product.price) ?? "")
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func restore() {
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
    
    @IBAction func subscribe() {
        MatreshkaHelper.shared.makeInAppSubscription(identifier: nil) {
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func privacyAction() {
        if let url = URL(string: "\(MatreshkaHelper.webDomain)/privacy") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func termsAction() {
        if let url = URL(string: "\(MatreshkaHelper.webDomain)/oferta") {
            UIApplication.shared.open(url)
        }
    }
}
