//
//  AppleSignInBulletinPage.swift
//  SMS Virtual
//
//  Created by Alexey Voronov on 14.12.2021.
//

import UIKit
import BLTNBoard


@objc class EmailCodeBulletinPage: BLTNPageItem {
    
    var textInputHandler: ((String) -> ())?
    //var field = KAPinField()
    var field = TextField()
    
    public override init(title: String) {
        super.init(title: title)
        
        self.isDismissable = true
        //self.descriptionText = "Авторизация необходима, что бы сохранять информацию о ваших подписках"
        //self.image = UIImage(named: "shieldBig")
        
        self.appearance.titleFontSize = 26
        self.appearance.titleTextColor = .white
        self.appearance.descriptionFontSize = 17
        self.appearance.descriptionTextColor = .white.withAlphaComponent(0.5)
    }
    
    override public func makeViewsUnderTitle(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
//        field.properties.numberOfCharacters = 6
//        field.properties.keyboardType = .decimalPad
//        field.appearance.textColor = .white
//        field.appearance.tokenColor = .white
//        field.appearance.backColor = .clear
//        field.appearance.backBorderFocusColor = .white
//        field.appearance.tokenFocusColor = .white
//        field.appearance.backBorderFocusColor = .clear
//        field.appearance.backBorderActiveColor = .clear
        
        field.placeholder = ""
        field.returnKeyType = .continue
        field.delegate = self
        field.cornerRadius = 12
        field.clipsToBounds = true
        field.backgroundColor = UIColor.white.withAlphaComponent(0.04)
        field.textColor = UIColor.white
        field.textContentType = .emailAddress
        field.font = UIFont(name: "SFProRounded-Medium", size: 19)
        
        field.keyboardType = .decimalPad
        
        field.delegate = self

        let emailFieldItem = interfaceBuilder.wrapView(field, width: nil, height: 48, position: .pinnedToEdges)
        
        
        let actionButton = interfaceBuilder.makeActionButton(title: "continue".localized)
        actionButton.cornerRadius = 18
        actionButton.borderColor = UIColor(named: "ColorTint")
        actionButton.tintColor = .white
        actionButton.button.titleLabel?.font = UIFont(name: "SFProRounded-Bold", size: 18)!
        actionButton.button.addTarget(self, action: #selector(actionButtonTap), for: .touchUpInside)
        
        
        
        return [emailFieldItem, actionButton]
    }
    
    @objc func actionButtonTap() {
        self.textFieldShouldReturn(field)
    }
}


extension EmailCodeBulletinPage: UITextFieldDelegate {
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
            //print(textField.text)
            textInputHandler?(field.text ?? "")
            
            textField.resignFirstResponder()

            return true
        }
}
