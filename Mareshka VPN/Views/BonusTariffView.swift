//
//  BonusTariffView.swift
//  Mareshka VPN (new)
//
//  Created by Alexey Voronov on 09.07.2022.
//

import UIKit
import LinearProgressBar

@IBDesignable
class BonusTariffView: UIView, NibLoadable {
    var id: String = ""
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: LinearProgressBar!
    @IBOutlet weak var button: UIButton!
    
    var delegate: BonusTariffViewDelegate?
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
    }
    
    func setup(tariff: TariffDTO, balance: Int) {
        self.id = tariff.id?.uuidString ?? ""
        
        titleLabel.text = "\(tariff.duration ?? 0) " + (tariff.durationType?.rawValue ?? "").localized
        priceLabel.text = "points".localized(tariff.ballCost ?? 0)
        progressLabel.text = String(balance > (tariff.ballCost ?? 0) ? (tariff.ballCost ?? 0) : balance) + " / "
        
        progressView.progressValue = Double(balance > (tariff.ballCost ?? 0) ? (tariff.ballCost ?? 0) : balance) / Double(tariff.ballCost ?? 0) * 100.0
        
        
        button.isHidden = balance >= (tariff.ballCost ?? 0) ? false : true
        progressView.isHidden = balance >= (tariff.ballCost ?? 0) ? true : false
        
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    }
    
    @objc func buttonAction() {
        delegate?.tariffSelectAction(id: id)
    }
}


protocol BonusTariffViewDelegate {
    func tariffSelectAction(id: String)
}
