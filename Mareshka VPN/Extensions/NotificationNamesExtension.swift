//
//  NotificationNamesExtension.swift
//  Mareshka VPN (new)
//
//  Created by Alexey Voronov on 23.06.2022.
//

import Foundation


extension Notification.Name {
    static var userProfileUpdate: Notification.Name {
        return .init(rawValue: "UserProfileUpdate")
    }
    
    static var selectedServerUpdate: Notification.Name {
        return .init(rawValue: "SelectedServerUpdate")
    }
    
    static var menuCellsUpdate: Notification.Name {
        return .init(rawValue: "MenuCellsUpdate")
    }
    
    static var successPurchase: Notification.Name {
        return .init(rawValue: "SuccessPurchase")
    }
}
