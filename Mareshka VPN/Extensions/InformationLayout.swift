//
//  informationLayout.swift
//  Navigator X
//
//  Created by Alexey on 15.10.2020.
//  Copyright © 2020 a2803. All rights reserved.
//

import Foundation
import FloatingPanel


class InformationLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .full
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            //.hidden: FloatingPanelLayoutAnchor(absoluteInset: 0.0, edge: .bottom, referenceGuide: .superview),
            //.half: FloatingPanelLayoutAnchor(absoluteInset: 375.0, edge: .bottom, referenceGuide: .safeArea),
            //.tip: FloatingPanelLayoutAnchor(absoluteInset: 139.0, edge: .bottom, referenceGuide: .safeArea),
            .full: FloatingPanelLayoutAnchor(absoluteInset: 390.0, edge: .bottom, referenceGuide: .safeArea),
        ]
    }
}
