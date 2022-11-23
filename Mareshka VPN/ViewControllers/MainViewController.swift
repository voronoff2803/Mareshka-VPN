//
//  MainViewController.swift
//  Matreshka VPN
//
//  Created by Alexey Voronov on 23.03.2022.
//

import UIKit
import NetworkExtension
import Nuke
import SwiftRater
import FirebaseAnalytics


class MainViewController: RootViewController {
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var firstCircle: UIImageView!
    @IBOutlet weak var secondCircle: UIImageView!
    @IBOutlet weak var onOffIcon: UIView!
    @IBOutlet weak var currentServerView: UIView!
    @IBOutlet weak var downloadLabel: UILabel!
    @IBOutlet weak var uploadLabel: UILabel!
    
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var bannerImage: UIImageView!
    
    var timer: Timer?
    var currentStatus: NEVPNStatus!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(currentServerChange))
        currentServerView.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector:#selector(selectedServerChanged(_:)), name: .selectedServerUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(profileUpdate), name: .userProfileUpdate, object: nil)
        
        if let server = MatreshkaHelper.shared.getSelectedServer() {
            mainLabel.text = server.country
            secondLabel.text = server.city
            flagImageView.image = UIImage(named: server.countryCode ?? "")
        }
        
        vpnStateChanged(status: WWVPNManager.shared.status)
        WWVPNManager.shared.statusEvent.attach(self,  MainViewController.vpnStateChanged)
        
        //setLoadState(isLoading: true)
    }
    
    @objc func profileUpdate() {
        getDataUsage()
        

        if let url = URL(string: MatreshkaHelper.domain + "/api/v1/system/ad-image") {
            let options = ImageLoadingOptions(
              transition: .fadeIn(duration: 0.5)
            )
             
            DispatchQueue.main.async {
                Nuke.loadImage(with: url, options: options, into: self.bannerImage) { result in
                    switch result {
                    case .success( _):
                        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.bannerAction))
                        self.bannerImage.gestureRecognizers?.forEach({self.bannerImage.removeGestureRecognizer($0)})
                        self.bannerImage?.addGestureRecognizer(tap2)
                    case .failure(_):
                        break
                    }
                }
            }
        }
        
        //setLoadState(isLoading: false)
    }
    
    func vpnStateChanged(status: NEVPNStatus) {
        self.currentStatus = status
        switch status {
        case .connected:
            print("MainVC connected")
            
            UserDefaults.standard.setValue(SystemDataUsage.upload, forKey: "p_upload")
            UserDefaults.standard.setValue(SystemDataUsage.download, forKey: "p_download")
            
            UserDefaults.standard.synchronize()
            
            setState(activate: true)
            setLoadState(isLoading: false)
            
            if self.timer == nil {
                self.timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (timer) in
                    self.getDataUsage()
                }
            }
            
        case .disconnected:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.setLoadState(isLoading: false)
                self.setState(activate: false)
                self.timer?.invalidate()
                self.timer = nil
            }
            
        case .connecting, .disconnecting:
            setLoadState(isLoading: true)
        default :
            setLoadState(isLoading: false)
        }
    }
    
    func getDataUsage() {
        if currentStatus != .connected {
            self.downloadLabel.text = Units(bytes: 0).getReadableUnit()
            self.uploadLabel.text = Units(bytes: 0).getReadableUnit()
        } else {
            let p_upload = UserDefaults.standard.value(forKey: "p_upload") as? UInt64 ?? 0
            let p_download = UserDefaults.standard.value(forKey: "p_download") as? UInt64 ?? 0
            guard SystemDataUsage.upload > p_upload else { return }
            guard SystemDataUsage.download > p_download else { return }
            let upload =  (SystemDataUsage.upload &- p_upload)
            let download =  (SystemDataUsage.download &- p_download)
            
            DispatchQueue.main.async {
                self.downloadLabel.text = Units(bytes: download).getReadableUnit()
                self.uploadLabel.text = Units(bytes: upload).getReadableUnit()
                
                if SwiftRater.isRateDone == false {
                    if download > 1024 * 100 {
                        SwiftRater.check(host: self)
                    }
                }
            }
        }
    }
    
    @objc func selectedServerChanged(_ notification: Notification) {
        guard let serverId = notification.object as? String else { return }
        guard let server = MatreshkaHelper.shared.serversList.first(where: {$0.id?.description == serverId}) else { return }
        
        mainLabel.text = server.country
        secondLabel.text = server.city
        flagImageView.image = UIImage(named: server.countryCode ?? "")
        
        FirebaseAnalytics.Analytics.logEvent("click_country", parameters: ["vpn_country": server.country ?? ""])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        if SwiftRater.isRateDone == false {
//
//            SwiftRater.check(host: self)
//        }
    }
    
    @objc func bannerAction() {
        if let url = URL(string: MatreshkaHelper.shared.systemGlobalConfig.bannerRedirect ?? "") {
            UIApplication.shared.open(url)
        }
    }
    
    
    @objc func currentServerChange() {
        if currentStatus == .connected {
            mainAction()
        } else {
            performSegue(withIdentifier: "servers", sender: nil)
        }
    }
    
    
    @IBAction func mainAction() {
        
        if !MatreshkaHelper.shared.isSubscriptionActive() && currentStatus != .connected {
            self.tabBarController?.selectedIndex = 1
            return
        }
        switch currentStatus {
        case .disconnected, .invalid, .none:
            MatreshkaHelper.shared.connectVPN()
        case .connected:
            MatreshkaHelper.shared.disconnectVPN()
            MatreshkaHelper.shared.sendDataUsage(true)
        case .some(_):
            break
        }
        //setLoadState(isLoading: true)
    }
    
    // UI Animations
    
    func setLoadState(isLoading: Bool) {
        UIView.animate(withDuration: 0.15, delay: 0.0) {
            self.onOffIcon.tintColor = isLoading ? .systemBlue : self.onOffIcon.tintColor
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.05) {
            self.secondCircle.tintColor = isLoading ? .systemBlue : self.onOffIcon.tintColor
        }
        
        UIView.animate(withDuration: 0.25, delay: 0.1) {
            self.firstCircle.tintColor = isLoading ? .systemBlue : self.onOffIcon.tintColor
        }
        
        if isLoading {
            UIView.animate(withDuration: 0.3, delay: 0.00, options: [.repeat, .autoreverse, .curveEaseInOut]) {
                self.onOffIcon.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }
            
            UIView.animate(withDuration: 0.3, delay: 0.04, options: [.repeat, .autoreverse, .curveEaseInOut]) {
                self.secondCircle.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
            }
            
            UIView.animate(withDuration: 0.3, delay: 0.11, options: [.repeat, .autoreverse, .curveEaseInOut]) {
                self.firstCircle.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }
        } else {
            UIView.animate(withDuration: 0.3, delay: 0.00, options: [.curveEaseInOut, .beginFromCurrentState]) {
                self.onOffIcon.transform = .identity
            }
            
            UIView.animate(withDuration: 0.3, delay: 0.04, options: [.curveEaseInOut, .beginFromCurrentState]) {
                self.secondCircle.transform = .identity
            }
            
            UIView.animate(withDuration: 0.3, delay: 0.11, options: [.curveEaseInOut, .beginFromCurrentState]) {
                self.firstCircle.transform =  .identity
            }
        }
    }
    
    
    func setState(activate: Bool) {
        
        UIView.animate(withDuration: 0.1, delay: 0.0) {
            self.onOffIcon.tintColor = activate ? .systemGreen : .systemRed
        }
        UIView.animate(withDuration: 0.1, delay: 0.1) {
            self.secondCircle.tintColor = activate ? .systemGreen : .systemRed
        }
        UIView.animate(withDuration: 0.1, delay: 0.2) {
            self.firstCircle.tintColor = activate ? .systemGreen : .systemRed
        }
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self, name:  .selectedServerUpdate, object: nil)
        NotificationCenter.default.removeObserver(self, name:  .userProfileUpdate, object: nil)
        timer?.invalidate()
    }
}
