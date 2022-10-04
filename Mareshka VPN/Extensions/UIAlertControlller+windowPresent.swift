//
//  UIAlertControlller+windowPresent.swift
//  Mareshka VPN (new)
//
//  Created by Alexey Voronov on 11.07.2022.
//

import UIKit

private var associationKey: UInt8 = 0

extension UIAlertController {

    private var alertWindow: UIWindow! {
        get {
            return objc_getAssociatedObject(self, &associationKey) as? UIWindow
        }

        set(newValue) {
            objc_setAssociatedObject(self, &associationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

    func show() {
        self.alertWindow = UIWindow.init(frame: UIScreen.main.bounds)
        self.alertWindow.overrideUserInterfaceStyle = .dark
        //self.alertWindow.backgroundColor = .red

        let viewController = UIViewController()
        //viewController.view.backgroundColor = .green
        self.alertWindow.rootViewController = viewController

        let topWindow = UIApplication.shared.windows.last
        if let topWindow = topWindow {
            self.alertWindow.windowLevel = topWindow.windowLevel + 1
        }

        self.alertWindow.makeKeyAndVisible()
        self.alertWindow.rootViewController?.present(self, animated: true, completion: nil)
    }

    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.alertWindow.isHidden = true
        self.alertWindow = nil
    }
}
