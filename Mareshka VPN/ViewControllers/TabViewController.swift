//
//  TabViewController.swift
//  Matreshka VPN
//
//  Created by Alexey Voronov on 27.03.2022.
//

import UIKit

class TabViewController: UITabBarController {
    let api = MatreshkaHelper.shared
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            setText()
        }
        
        @objc func setText() {
            tabBar.items?[0].title = "main".localized
            tabBar.items?[1].title = "subscription".localized
            tabBar.items?[2].title = "profile".localized
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            NotificationCenter.default.removeObserver(self)
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        MatreshkaHelper.shared.tabBarVC = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.showOnBoard()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //showQRAuth()
    }
    
    func showQRAuth() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let qrAuthController = storyboard.instantiateViewController(withIdentifier: "QRAuthViewController") as! QRAuthViewController
        
        self.present(qrAuthController, animated: true)
    }
    
    func showOnBoard() {
        MatreshkaHelper.shared.getInfoScreens { screens in
            if !screens.isEmpty {
                let onboardingViewController = OnboardViewController(pageItems: screens)
                onboardingViewController.presentFrom(self, animated: true)
            }
        }
    }
}
