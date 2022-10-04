//
//  LocalisableLabel.swift
//  Mareshka VPN (new)
//
//  Created by Alexey Voronov on 26.06.2022.
//

import UIKit


class LocalisableLabel: UILabel {
    @IBInspectable var localisedKey: String? {
        didSet {
            guard let key = localisedKey else { return }
            text = NSLocalizedString(key, comment: "")
        }
    }
}
