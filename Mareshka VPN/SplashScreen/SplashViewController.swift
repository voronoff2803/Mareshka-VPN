//
//  SplashViewController.swift
//  Mareshka VPN
//
//  Created by Alexey Voronov on 31.08.2022.
//

import UIKit

class SplashViewController: UIViewController {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    static let logoMask = UIImage(named: "matrshkaMask")!
    static let logoImage = UIImage(named: "logoSplash")!
    
    var frazeString: String?
    
    static let frazes = [
        "splash1",
        "splash2",
        "splash3",
        "splash4",
        "splash5",
        "splash6",
        "splash7",
        "splash8",
        "splash9",
        "splash10",
        "splash11",
        "splash12",
        "splash13"
        ]
    
    var logoIsHidden = false
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textLabel.text = frazeString
        logoImageView.isHidden = logoIsHidden
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) { [weak self] in
            self?.textLabel.changeText(text: "connectionError".localized)
        }
    }
}
