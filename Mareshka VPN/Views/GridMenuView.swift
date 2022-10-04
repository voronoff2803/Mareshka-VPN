//
//  GridMenuView.swift
//  Mareshka VPN
//
//  Created by Alexey Voronov on 26.09.2022.
//

import UIKit

@IBDesignable
class GridMenuView: UIView, NibLoadable {
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBInspectable
    var titleText: String = "" {
        didSet {
            titleLabel.text = titleText
        }
    }
    
    @IBInspectable
    var imageIcon: UIImage = UIImage() {
        didSet {
            iconImage.image = imageIcon
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        iconImage.tintColor = self.tintColor
        
        self.alpha = titleText == "" ? 0.0 : 1.0
    }
}
