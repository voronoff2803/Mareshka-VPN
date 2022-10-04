//
//  String+Localized.swift
//  SMS Virtual SwiftUI
//
//  Created by Alexey Voronov on 13.08.2021.
//

import Foundation

extension String {
    
    var localized: String {
        return NSLocalizedString(self, comment: self)
    }
    
    func localized(_ arguments: CVarArg...) -> String {
        let args = arguments.map {
            if let arg = $0 as? Int { return String(arg) }
            if let arg = $0 as? Float { return String(arg) }
            if let arg = $0 as? Double { return String(arg) }
            if let arg = $0 as? Int64 { return String(arg) }
            if let arg = $0 as? String { return String(arg) }
            
            return "(null)"
        } as [CVarArg]
        
        return String.init(format: localized, arguments: args)
    }
    func localized(lang:String) -> String {
        guard let path = Bundle.main.path(forResource: lang, ofType: "lproj") else {return self.localized}
        let bundle = Bundle(path: path)

        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
}
