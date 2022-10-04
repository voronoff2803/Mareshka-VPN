//
//  PaymentView.swift
//  Mareshka VPN
//
//  Created by Alexey Voronov on 09.08.2022.
//

import UIKit


class PaymentView: UIView, NibLoadable {
    var handler: (() -> ())?
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
    }
    
    @IBAction func buttonAction() {
        handler?()
    }
}

