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
    @IBOutlet weak var blobView: ActivityBlobView!
    @IBOutlet weak var ioButton: UIButton!
    @IBOutlet weak var currentServerView: UIView!
    @IBOutlet weak var downloadLabel: UILabel!
    @IBOutlet weak var uploadLabel: UILabel!
    
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    
    var timer: Timer?
    
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
        
        ioButton.addTarget(self, action: #selector(mainButtonUp), for: .touchUpInside)
        ioButton.addTarget(self, action: #selector(mainButtonUp), for: .touchUpOutside)
        ioButton.addTarget(self, action: #selector(mainButtonDown), for: .touchDown)
        
        ioButton.layer.compositingFilter = "lightenBlendMode"
    }
    
    @objc func mainButtonUp() {
        blobView.setOnTap(isTap: false)
    }
    
    @objc func mainButtonDown() {
        blobView.setOnTap(isTap: true)
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
            self.setLoadState(isLoading: false)
            self.setState(activate: false)
            self.timer?.invalidate()
            self.timer = nil
            
            if shouldForceConnect {
                shouldForceConnect = false
                MatreshkaHelper.shared.connectVPN()
            }
        case .connecting, .disconnecting:
            setLoadState(isLoading: true)
        default :
            setLoadState(isLoading: false)
        }
        
        switch status {
        case .connected:
            self.statusLabel.changeText(text: "CONNECTED".localized)
            self.ioButton.setImageTintColor(UIColor(hex: "#36FA24FF")!)
            self.blobView.state = .connected
        case .disconnected:
            self.statusLabel.changeText(text: "DISCONNECTED".localized)
            self.ioButton.setImageTintColor(UIColor(hex: "#9077FFFF")!)
            self.blobView.state = .disconnected
        case .connecting:
            self.statusLabel.changeText(text: "CONNECTING".localized)
            self.ioButton.setImageTintColor(UIColor(hex: "#9077FF55")!)
            self.blobView.state = .loading
        case .disconnecting:
            self.statusLabel.changeText(text: "DISCONNECTING".localized)
            self.ioButton.setImageTintColor(UIColor(hex: "#9077FF55")!)
            self.blobView.state = .loading
        default :
            self.statusLabel.changeText(text: "DISCONNECTED".localized)
            self.ioButton.setImageTintColor(UIColor(hex: "#9077FFFF")!)
            self.blobView.state = .disconnected
        }
    }
    
    func getDataUsage() {
        if WWVPNManager.shared.status != .connected {
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
                    if download > 1024 * 1024 {
                        SwiftRater.check(host: self)
                    }
                }
            }
        }
    }
    
    var shouldForceConnect = false
    
    @objc func selectedServerChanged(_ notification: Notification) {
        guard let onStart = notification.object as? Bool else { return }
        
        let serverId = MatreshkaHelper.shared.selectedServerId
        guard let server = MatreshkaHelper.shared.serversList.first(where: {$0.id?.description == serverId}) else { return }
        
        mainLabel.text = server.country
        secondLabel.text = server.city
        flagImageView.image = UIImage(named: server.countryCode ?? "")
        
        if !onStart {
            FirebaseAnalytics.Analytics.logEvent("click_country", parameters: ["vpn_country": server.country ?? ""])
            if WWVPNManager.shared.status == .connected {
                MatreshkaHelper.shared.disconnectVPN() {
                    self.shouldForceConnect = true
                }
                MatreshkaHelper.shared.sendDataUsage(true)
            }
        }
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
        performSegue(withIdentifier: "servers", sender: nil)
    }
    
    
    @IBAction func mainAction() {
        
        if !MatreshkaHelper.shared.isSubscriptionActive() && WWVPNManager.shared.status != .connected {
            self.tabBarController?.selectedIndex = 1
            return
        }
        switch WWVPNManager.shared.status {
        case .disconnected, .invalid:
            MatreshkaHelper.shared.connectVPN()
        case .connected:
            MatreshkaHelper.shared.disconnectVPN()
            MatreshkaHelper.shared.sendDataUsage(true)
            setLoadState(isLoading: true)
        default:
            break
        }
    }
    // UI Animations
    
    func setLoadState(isLoading: Bool) {
        print(#function, isLoading)
        
    }
    
    
    func setState(activate: Bool) {
        
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self, name:  .selectedServerUpdate, object: nil)
        NotificationCenter.default.removeObserver(self, name:  .userProfileUpdate, object: nil)
        timer?.invalidate()
    }
}
