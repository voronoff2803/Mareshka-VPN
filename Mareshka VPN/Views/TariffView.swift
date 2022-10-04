//
//  TariffView.swift
//  Mareshka VPN
//
//  Created by Alexey Voronov on 09.08.2022.
//

import UIKit

@IBDesignable
class TariffView: UIView, NibLoadable {
    var tariff: TariffDTO?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var saleLabel: UILabel!
    @IBOutlet weak var saleView: UIView!
    @IBOutlet weak var button: UIButton!
    
    var delegate: TariffViewDelegate?
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
    }
    
    func setup(tariff: TariffDTO) {
        self.tariff = tariff
        
        if let discount = tariff.discount {
            saleView.isHidden = false
            saleLabel.text = "discountValue".localized(discount)
        } else {
            saleView.isHidden = true
        }
        
        let languageCode = Locale.current.languageCode ?? ""
        
        switch languageCode {
        case _ where languageCode.contains("ru"):
            priceLabel.text = String(format: "%.2f₽", tariff.ruPrice ?? 0)
        case _ where languageCode.contains("en"):
            priceLabel.text = String(format: "%.2f$", tariff.enPrice ?? 0)
        case _ where languageCode.contains("zh"):
            priceLabel.text = String(format: "%.2f¥", tariff.chPrice ?? 0)
        default:
            priceLabel.text = String(format: "%.2f$", tariff.enPrice ?? 0)
        }
        
        titleLabel.text = tariff.name
        
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    }
    
    @objc func buttonAction() {
        if let tariff = tariff {
            delegate?.tariffSelectAction(tariff: tariff)
        }
    }
}


protocol TariffViewDelegate {
    func tariffSelectAction(tariff: TariffDTO)
}

