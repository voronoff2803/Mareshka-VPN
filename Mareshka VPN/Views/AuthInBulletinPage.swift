//
//  AppleSignInBulletinPage.swift
//  SMS Virtual
//
//  Created by Alexey Voronov on 14.12.2021.
//

import UIKit
import BLTNBoard
import AuthenticationServices
import FirebaseAnalytics


@objc public class AuthInBulletinPage: BLTNPageItem {
    
    var emailButtonAction: (() -> ())?
    var appleButtonAction: (() -> ())?
    var googleButtonAction: (() -> ())?
    
    public override init(title: String) {
        super.init(title: title)
        
        self.isDismissable = true
        self.descriptionText = "authInfo".localized
        self.image = UIImage(named: "shieldBig")
        
        self.appearance.titleFontSize = 26
        self.appearance.titleTextColor = .white
        self.appearance.descriptionFontSize = 17
        self.appearance.descriptionTextColor = .white.withAlphaComponent(0.5)
        
        FirebaseAnalytics.Analytics.logEvent("registrationstart", parameters: nil)
    }
    
    override public func makeViewsUnderDescription(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        
        let appleSignInButton = UIButton()
        appleSignInButton.layer.cornerRadius = 18
        appleSignInButton.clipsToBounds = true
        appleSignInButton.backgroundColor = UIColor.white.withAlphaComponent(0.04)
        appleSignInButton.layer.borderWidth = 1.0
        appleSignInButton.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
        appleSignInButton.setTitle("appleSignIn".localized, for: .normal)
        appleSignInButton.setTitleColor(UIColor.label, for: .normal)
        appleSignInButton.setTitleColor(UIColor.label.withAlphaComponent(0.2), for: .highlighted)
        appleSignInButton.titleLabel?.font = UIFont(name: "SFProRounded-Medium", size: 19)
        appleSignInButton.addTarget(self, action: #selector(appleSignIn), for: .touchUpInside)
        appleSignInButton.setImage(UIImage(named: "appleLogo"), for: .normal)
        appleSignInButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        
        let appleSignInButtonItem = interfaceBuilder.wrapView(appleSignInButton, width: nil, height: 48, position: .pinnedToEdges)
        
        let googleSignInButton = UIButton()
        googleSignInButton.layer.cornerRadius = 18
        googleSignInButton.clipsToBounds = true
        googleSignInButton.backgroundColor = UIColor.white.withAlphaComponent(0.04)
        googleSignInButton.layer.borderWidth = 1.0
        googleSignInButton.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
        googleSignInButton.setTitle("googleSignIn".localized, for: .normal)
        googleSignInButton.setTitleColor(UIColor.label, for: .normal)
        googleSignInButton.setTitleColor(UIColor.label.withAlphaComponent(0.2), for: .highlighted)
        googleSignInButton.titleLabel?.font = UIFont(name: "SFProRounded-Medium", size: 19)
        googleSignInButton.addTarget(self, action: #selector(googleSignIn), for: .touchUpInside)
        googleSignInButton.setImage(UIImage(named: "Google"), for: .normal)
        googleSignInButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        
        let googleSignInButtonItem = interfaceBuilder.wrapView(googleSignInButton, width: nil, height: 48, position: .pinnedToEdges)
        googleSignInButtonItem.cornerRadius = 12
        
        let emailSignInButton = UIButton()
        emailSignInButton.layer.cornerRadius = 18
        emailSignInButton.clipsToBounds = true
        emailSignInButton.backgroundColor = UIColor.white.withAlphaComponent(0.04)
        emailSignInButton.layer.borderWidth = 1.0
        emailSignInButton.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
        emailSignInButton.setTitle("emailSignIn".localized, for: .normal)
        emailSignInButton.setTitleColor(UIColor.label, for: .normal)
        emailSignInButton.setTitleColor(UIColor.label.withAlphaComponent(0.2), for: .highlighted)
        emailSignInButton.titleLabel?.font = UIFont(name: "SFProRounded-Medium", size: 19)
        emailSignInButton.addTarget(self, action: #selector(emailSignIn), for: .touchUpInside)
        emailSignInButton.setImage(UIImage(named: "email"), for: .normal)
        emailSignInButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        
        let emailSignInButtonItem = interfaceBuilder.wrapView(emailSignInButton, width: nil, height: 48, position: .pinnedToEdges)
        emailSignInButtonItem.cornerRadius = 12
        
        
        return [appleSignInButtonItem, googleSignInButtonItem, emailSignInButtonItem]
    }
    
    @objc func appleSignIn() {
        appleButtonAction?()
    }
    
    @objc func googleSignIn() {
        googleButtonAction?()
    }
    
    @objc func emailSignIn() {
        self.emailButtonAction?()
    }
}
