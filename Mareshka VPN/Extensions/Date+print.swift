//
//  Date+print.swift
//  Mareshka VPN (new)
//
//  Created by Alexey Voronov on 23.06.2022.
//

import Foundation


extension Date {
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.dateFormat = "dd MMM, yyyy"
        formatter.locale = Locale.current
        return formatter.string(from: self)
    }
}
