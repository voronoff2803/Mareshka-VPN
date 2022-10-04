//
//  ServerCell.swift
//  Matreshka VPN
//
//  Created by Alexey Voronov on 24.03.2022.
//

import UIKit
import SwiftyPing


class ServerCell: UITableViewCell {
    @IBOutlet weak var serverSwitch: UISwitch!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var pingImageView: UIImageView!
    
    var server: ServerDTO?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectAction))
        self.contentView.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector:#selector(selectedServerChanged(_:)), name: .selectedServerUpdate, object: nil)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func selectAction() {
        NotificationCenter.default.post(name: .selectedServerUpdate, object: server?.id?.uuidString)
        MatreshkaHelper.shared.selectedServerId = server?.id?.uuidString ?? ""
    }
    
    @objc func selectedServerChanged(_ notification: Notification) {
        guard let serverId = notification.object as? String else { return }
        if serverId == server?.id?.description {
            serverSwitch.setOn(true, animated: true)
        } else if serverSwitch.isOn {
            serverSwitch.setOn(false, animated: true)
        }
    }
    
    func setup(server: ServerDTO) {
        self.server = server
        
        self.flagImageView.image = UIImage(named: server.countryCode ?? "")
        self.mainLabel.text = server.country
        self.secondLabel.text = server.city
        
        if MatreshkaHelper.shared.selectedServerId == server.id?.description {
            serverSwitch.setOn(true, animated: false)
        } else {
            serverSwitch.setOn(false, animated: false)
        }
        pingImageView.isHidden = true
        
        if let ping = server.ping {
            stupPingUI(ms: ping)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name:  .selectedServerUpdate, object: nil)
    }
    
    func stupPingUI(ms: Double) {
        pingImageView.isHidden = false
        switch ms {
        case 1:
            self.pingImageView.image = UIImage()
        case 2...50:
            self.pingImageView.image = UIImage(named: "signal5")
        case 51...90:
            self.pingImageView.image = UIImage(named: "signal4")
        case 91...130:
            self.pingImageView.image = UIImage(named: "signal3")
        case 131...230:
            self.pingImageView.image = UIImage(named: "signal2")
        default:
            self.pingImageView.image = UIImage(named: "signal1")
        }
    }
}

extension UITableViewCell{
    
    var tableView:UITableView?{
        return superview as? UITableView
    }
    
    var indexPath:IndexPath?{
        return tableView?.indexPath(for: self)
    }
    
}

extension TimeInterval {
    var millisecond: Int {
        Int((self*1000).truncatingRemainder(dividingBy: 1000))
    }
}
