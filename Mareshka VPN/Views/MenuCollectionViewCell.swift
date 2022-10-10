//
//  MenuCollectionViewCell.swift
//  Mareshka VPN
//
//  Created by Alexey Voronov on 05.10.2022.
//

import UIKit

class MenuCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    func setup(model: MenuCellModel) {
        titleLabel.text = model.title
        iconImageView.image = model.icon
        self.tintColor = model.color
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let transform = self.transform.scaledBy(x: 0.9, y: 0.9)
        self.layer.opacity = 1.0
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.1) {
                self.layer.opacity = 0.5
                self.transform = transform
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                self.layer.opacity = 1.0
                self.transform = .identity
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                self.layer.opacity = 1.0
                self.transform = .identity
            }
        }
    }
}
