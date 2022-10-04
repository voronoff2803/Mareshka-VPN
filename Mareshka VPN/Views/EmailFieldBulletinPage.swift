//
//  AppleSignInBulletinPage.swift
//  SMS Virtual
//
//  Created by Alexey Voronov on 14.12.2021.
//

import UIKit
import BLTNBoard


@objc class EmailFieldBulletinPage: BLTNPageItem {
    
    var textInputHandler: ((String) -> ())?
    var emailField = TextField()
    
    public override init(title: String) {
        super.init(title: title)
        
        self.isDismissable = true
        self.descriptionText = "emailInfo".localized
        //self.image = UIImage(named: "shieldBig")
        
        self.appearance.titleFontSize = 26
        self.appearance.titleTextColor = .white
        self.appearance.descriptionFontSize = 17
        self.appearance.descriptionTextColor = .white.withAlphaComponent(0.5)

    }
    
    override public func makeViewsUnderDescription(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        
        emailField.placeholder = "examplemail".localized
        emailField.returnKeyType = .continue
        emailField.delegate = self
        emailField.cornerRadius = 12
        emailField.clipsToBounds = true
        emailField.backgroundColor = UIColor.white.withAlphaComponent(0.04)
        emailField.textColor = UIColor.white
        emailField.textContentType = .emailAddress
        emailField.font = UIFont(name: "SFProRounded-Medium", size: 19)
        emailField.textContentType = .emailAddress
        emailField.autocapitalizationType = .none

        let emailFieldItem = interfaceBuilder.wrapView(emailField, width: nil, height: 48, position: .pinnedToEdges)
        
        
        let actionButton = interfaceBuilder.makeActionButton(title: "continue".localized)
        actionButton.cornerRadius = 18
        actionButton.borderColor = UIColor(named: "ColorTint")
        actionButton.tintColor = .white
        actionButton.button.titleLabel?.font = UIFont(name: "SFProRounded-Bold", size: 18)!
        actionButton.button.addTarget(self, action: #selector(actionButtonTap), for: .touchUpInside)
        
        
        return [emailFieldItem, actionButton]
    }
    
    @objc func actionButtonTap() {
        self.textFieldShouldReturn(emailField)
    }
}


extension EmailFieldBulletinPage: UITextFieldDelegate {
    @objc open func isInputValid(text: String?) -> Bool {

            if text == nil || text!.isEmpty {
                return false
            }

            return true

        }

        public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
            return true
        }

        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if isInputValid(text: textField.text) {
                textInputHandler?(emailField.text ?? "")
            } else {
                textField.backgroundColor = UIColor.red.withAlphaComponent(0.3)
            }
            
            textField.resignFirstResponder()
            return true
        }
}
