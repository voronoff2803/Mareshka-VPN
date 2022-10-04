//
//  TextField.swift
//  Matreshka VPN
//
//  Created by Alexey Voronov on 25.03.2022.
//

import UIKit


class TextField: UITextField {

    let padding = UIEdgeInsets(top: 0, left: 11, bottom: 0, right: 5)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
