//
//  LocalisableButton.swift
//  Mareshka VPN (new)
//
//  Created by Alexey Voronov on 26.06.2022.
//

import UIKit


class LocalisableButton: UIButton {

    @IBInspectable var localisedKey: String? {
        didSet {
            guard let key = localisedKey else { return }
            UIView.performWithoutAnimation {
                setTitle(key.localized, for: .normal)
                layoutIfNeeded()
            }
        }
    }

}
