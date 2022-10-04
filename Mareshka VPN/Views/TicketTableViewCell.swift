//
//  TicketTableViewCell.swift
//  Mareshka VPN (new)
//
//  Created by Alexey Voronov on 10.07.2022.
//

import UIKit

class TicketTableViewCell: UITableViewCell {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(ticket: WithdrawDTO) {
        statusLabel.text = ticket.state?.rawValue ?? ""
        contentLabel.text = ticket.card ?? ""
        countLabel.text = String(ticket.count ?? 0.0)
        emailLabel.text = ticket.email ?? ""
        
        guard let cardView = self.contentView.subviews.first else { return}
        
        switch ticket.state {
        case .new:
            cardView.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.16)
            cardView.layer.borderColor = UIColor.systemYellow.cgColor
        case .cancelled:
            cardView.backgroundColor = UIColor(named: "ColorSecond")!.withAlphaComponent(0.16)
            cardView.layer.borderColor = UIColor(named: "ColorSecond")!.cgColor
        case .executed:
            cardView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.16)
            cardView.layer.borderColor = UIColor.systemRed.cgColor
        case .none:
            break
        }
        
    }

}
