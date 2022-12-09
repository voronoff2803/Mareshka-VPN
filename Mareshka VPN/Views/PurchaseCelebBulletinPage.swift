//
//  PurchaseCelebBulletinPage.swift
//  Mareshka VPN
//
//  Created by Alexey Voronov on 30.11.2022.
//

import UIKit
import BLTNBoard
import AuthenticationServices
import FirebaseAnalytics


@objc public class PurchaseCelebBulletinPage: BLTNPageItem {
    public override init(title: String) {
        super.init(title: title)
        
        self.isDismissable = false
        self.descriptionText = "thanks".localized
        
        self.appearance.titleFontSize = 26
        self.appearance.titleTextColor = .white
        self.appearance.descriptionFontSize = 17
        self.appearance.descriptionTextColor = .white.withAlphaComponent(0.5)
        
        FirebaseAnalytics.Analytics.logEvent("registrationstart", parameters: nil)
        
        let bgImageView = UIImageView(image: UIImage(named: "purchaseCelebBG"))
        self.imageView?.addSubview(bgImageView)
        bgImageView.center = self.imageView?.center ?? .zero
        
    }
    
    override public func makeViewsUnderTitle(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        let imageView = UIImageView(image: UIImage(named: "purchaseCeleb"))
        let imageViewItem = interfaceBuilder.wrapView(imageView, width: nil, height: 150, position: .centered)
        let bgImageView = UIImageView(image: UIImage(named: "purchaseCelebBG"))
        imageViewItem.addSubview(bgImageView)
        
        bgImageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint(item: bgImageView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: imageViewItem, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: bgImageView, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: imageViewItem, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0).isActive = true
        
        return [imageViewItem]
    }
    
    override public func makeViewsUnderDescription(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        let emailSignInButton = UIButton()
        emailSignInButton.layer.cornerRadius = 18
        emailSignInButton.clipsToBounds = true
        emailSignInButton.backgroundColor = UIColor.white.withAlphaComponent(0.04)
        emailSignInButton.layer.borderWidth = 1.0
        emailSignInButton.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
        emailSignInButton.setTitle("continue".localized, for: .normal)
        emailSignInButton.setTitleColor(UIColor.white, for: .normal)
        emailSignInButton.setTitleColor(UIColor.white.withAlphaComponent(0.2), for: .highlighted)
        emailSignInButton.titleLabel?.font = UIFont(name: "SFProRounded-Medium", size: 19)
        emailSignInButton.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        
        let emailSignInButtonItem = interfaceBuilder.wrapView(emailSignInButton, width: nil, height: 48, position: .pinnedToEdges)
        emailSignInButtonItem.cornerRadius = 12
        
        
        return [emailSignInButtonItem]
    }
    
    @objc func dismissAction() {
        self.manager?.dismissBulletin(animated: true)
    }
}
