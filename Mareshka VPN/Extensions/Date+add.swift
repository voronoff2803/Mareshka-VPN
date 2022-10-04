//
//  Date+add.swift
//  Mareshka VPN (new)
//
//  Created by Alexey Voronov on 23.06.2022.
//

import Foundation


extension Date {
    func adding(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self)!
    }
}
