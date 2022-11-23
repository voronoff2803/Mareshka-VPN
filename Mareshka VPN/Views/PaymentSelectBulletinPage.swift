//
//  PaymentSelectBulletinPage.swift
//  Mareshka VPN
//
//  Created by Alexey Voronov on 09.08.2022.
//

import UIKit
import BLTNBoard
import AuthenticationServices
import FirebaseAnalytics



@objc public class PaymentSelectBulletinPage: BLTNPageItem {
    
    var tariff: TariffDTO
    
    var promocodeField = TextField()
    
    var delegate: TariffViewDelegate?
    
    var cardHandler: ((TariffDTO) -> ())?
    var qiwiHandler: ((TariffDTO) -> ())?
    var appleHandler: ((TariffDTO) -> ())?
    
    public init(tariff: TariffDTO) {
        let title = "\(tariff.duration ?? 0) " + (tariff.durationType?.rawValue ?? "").localized
        
        self.tariff = tariff
        
        super.init(title: title)
        
        self.isDismissable = true

        
        self.appearance.titleFontSize = 26
        self.appearance.titleTextColor = .white
        self.appearance.descriptionFontSize = 17
        self.appearance.descriptionTextColor = .white.withAlphaComponent(0.5)
        
        let languageCode = Locale.current.languageCode ?? ""
        
        var price = ""
        switch languageCode {
        case _ where languageCode.contains("ru"):
            price = String(format: "%.2f₽", tariff.ruPrice ?? 0)
        case _ where languageCode.contains("en"):
            price = String(format: "%.2f$", tariff.enPrice ?? 0)
        case _ where languageCode.contains("zh"):
            price = String(format: "%.2f¥", tariff.chPrice ?? 0)
        default:
            price = String(format: "%.2f$", tariff.enPrice ?? 0)
        }
        
        self.descriptionText = "price".localized(price)
        
        FirebaseAnalytics.Analytics.logEvent("click_product", parameters: ["product_id": tariff.id?.uuidString ?? "",
                                                                           "product_name": tariff.name ?? "",
                                                                           "price": tariff.enPrice ?? "",
                                                                           "currency": "USD"])
    }
    
    override public func makeViewsUnderDescription(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        promocodeField.returnKeyType = .continue
        promocodeField.cornerRadius = 12
        promocodeField.clipsToBounds = true
        promocodeField.backgroundColor = UIColor.white.withAlphaComponent(0.04)
        promocodeField.textColor = UIColor.white
        promocodeField.textContentType = .emailAddress
        promocodeField.font = UIFont(name: "SFProRounded-Medium", size: 19)
        promocodeField.textContentType = .emailAddress
        promocodeField.autocapitalizationType = .none
        promocodeField.attributedPlaceholder = NSAttributedString(
            string: "enterPromo".localized,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.17)]
        )
        promocodeField.delegate = self
        promocodeField.autocapitalizationType = .allCharacters
        
        let promocodeFieldItem = interfaceBuilder.wrapView(promocodeField, width: nil, height: 48, position: .pinnedToEdges)
        
        let paymentView1 = PaymentView()
        paymentView1.handler = { MatreshkaHelper.shared.currentPromocode = self.promocodeField.text; self.cardHandler?(self.tariff) }
        paymentView1.titleLabel.text = "method1".localized
        paymentView1.descriptionLabel.text = "method1d".localized
        paymentView1.iconImage.image = UIImage(named: "cardIcon")
        let paymentViewItem1 = interfaceBuilder.wrapView(paymentView1, width: nil, height: 64, position: .pinnedToEdges)
        
        let paymentView2 = PaymentView()
        paymentView2.handler = { MatreshkaHelper.shared.currentPromocode = self.promocodeField.text; self.qiwiHandler?(self.tariff) }
        paymentView2.titleLabel.text = "method2".localized
        paymentView2.descriptionLabel.text = "method2d".localized
        paymentView2.iconImage.image = UIImage(named: "qiwiIcon")
        let paymentViewItem2 = interfaceBuilder.wrapView(paymentView2, width: nil, height: 64, position: .pinnedToEdges)
        
        let paymentView3 = PaymentView()
        paymentView3.handler = { MatreshkaHelper.shared.currentPromocode = self.promocodeField.text; self.appleHandler?(self.tariff) }
        paymentView3.titleLabel.text = "method3".localized
        paymentView3.descriptionLabel.text = "method3d".localized
        paymentView3.iconImage.image = UIImage(named: "applePayIcon")
        let paymentViewItem3 = interfaceBuilder.wrapView(paymentView3, width: nil, height: 64, position: .pinnedToEdges)
        
        
        return [paymentViewItem1, paymentViewItem2, paymentViewItem3, promocodeFieldItem]
    }
}




extension PaymentSelectBulletinPage: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        FirebaseAnalytics.Analytics.logEvent("promocode_click", parameters: nil)
        return true
    }
}
