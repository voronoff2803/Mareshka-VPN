//
//  CreateTicketBulletinPage.swift
//  Mareshka VPN (new)
//
//  Created by Alexey Voronov on 10.07.2022.
//

import UIKit
import BLTNBoard
import AuthenticationServices


@objc public class CreateTicketBulletinPage: BLTNPageItem {
    
    var emailField = TextField()
    var contentField = TextField()
    var countField = TextField()
    
    public override init(title: String) {
        super.init(title: title)
        
        self.isDismissable = true

        
        self.appearance.titleFontSize = 26
        self.appearance.titleTextColor = .white
        self.appearance.descriptionFontSize = 17
        self.appearance.descriptionTextColor = .white.withAlphaComponent(0.5)

    }
    
    override public func makeViewsUnderTitle(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        
        emailField.returnKeyType = .continue
        emailField.cornerRadius = 12
        emailField.clipsToBounds = true
        emailField.backgroundColor = UIColor.white.withAlphaComponent(0.04)
        emailField.textColor = UIColor.white
        emailField.textContentType = .emailAddress
        emailField.font = UIFont(name: "SFProRounded-Medium", size: 19)
        emailField.textContentType = .emailAddress
        emailField.autocapitalizationType = .none
        emailField.attributedPlaceholder = NSAttributedString(
            string: "email".localized,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.17)]
        )

        let emailFieldItem = interfaceBuilder.wrapView(emailField, width: nil, height: 48, position: .pinnedToEdges)
        
        
        contentField.returnKeyType = .continue
        contentField.cornerRadius = 12
        contentField.clipsToBounds = true
        contentField.backgroundColor = UIColor.white.withAlphaComponent(0.04)
        contentField.textColor = UIColor.white
        contentField.keyboardType = .numbersAndPunctuation
        contentField.font = UIFont(name: "SFProRounded-Medium", size: 19)
        contentField.textContentType = .emailAddress
        contentField.autocapitalizationType = .none
        contentField.attributedPlaceholder = NSAttributedString(
            string: "cardNumber".localized,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.17)]
        )

        let contentFieldItem = interfaceBuilder.wrapView(contentField, width: nil, height: 48, position: .pinnedToEdges)
        
        
        countField.returnKeyType = .continue
        countField.cornerRadius = 12
        countField.clipsToBounds = true
        countField.backgroundColor = UIColor.white.withAlphaComponent(0.04)
        countField.textColor = UIColor.white
        countField.keyboardType = .numbersAndPunctuation
        countField.font = UIFont(name: "SFProRounded-Medium", size: 19)
        countField.textContentType = .emailAddress
        countField.autocapitalizationType = .none
        countField.attributedPlaceholder = NSAttributedString(
            string: "count".localized,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.17)]
        )

        let countFieldItem = interfaceBuilder.wrapView(countField, width: nil, height: 48, position: .pinnedToEdges)
        
        let sendTicketAction = UIButton()
        
        sendTicketAction.addTarget(self, action: #selector(sendAction), for: .touchUpInside)
        sendTicketAction.setTitle("sendRequest".localized, for: .normal)
        sendTicketAction.cornerRadius = 12
        sendTicketAction.clipsToBounds = true
        sendTicketAction.backgroundColor = UIColor(named: "ColorSecond")
        sendTicketAction.setTitleColor(.white, for: .normal)
        sendTicketAction.titleLabel?.font = UIFont(name: "SFProRounded-Medium", size: 19)!

        let sendTicketActionItem = interfaceBuilder.wrapView(sendTicketAction, width: nil, height: 48, position: .pinnedToEdges)
        
        
        return [emailFieldItem, contentFieldItem, countFieldItem, sendTicketActionItem]
    }
    
    
    @objc func sendAction() {
        guard contentField.text != "" else { return }
        guard emailField.text != "" else { return }
        guard let count = Double(countField.text ?? "") else { return }
        MatreshkaHelper.shared.sendWithdraw(card: contentField.text, count: count, email: emailField.text) { result in
            self.manager?.dismissBulletin()
        }
    }
}
