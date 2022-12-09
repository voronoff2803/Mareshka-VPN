//
//  UIColor+RGB.swift
//  Test
//
//  Created by Alexey Voronov on 08.12.2022.
//

import UIKit

extension UIColor {
    typealias RGBA = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
    var rgba: RGBA? {
        var (r, g, b, a): RGBA = (0, 0, 0, 0)
        return getRed(&r, green: &g, blue: &b, alpha: &a) ? (r,g,b,a) : nil
    }
    var r: CGFloat? {
        var red: CGFloat = .zero
        return getRed(&red, green: nil, blue: nil, alpha: nil) ? red : nil
    }
    var g: CGFloat? {
        var green: CGFloat = .zero
        return getRed(nil, green: &green, blue: nil, alpha: nil) ? green : nil
    }
    var b: CGFloat? {
        var blue: CGFloat = .zero
        return getRed(nil, green: nil, blue: &blue, alpha: nil) ? blue : nil
    }
    var a: CGFloat? {
        var alpha: CGFloat = .zero
        return getRed(nil, green: nil, blue: nil, alpha: &alpha) ? alpha : nil
    }
}
