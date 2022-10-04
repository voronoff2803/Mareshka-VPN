//
//  TicketsViewController.swift
//  Mareshka VPN (new)
//
//  Created by Alexey Voronov on 10.07.2022.
//

import UIKit

class TicketsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var tickets: [WithdrawDTO] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        MatreshkaHelper.shared.getTickets { tickets in
            self.tickets = tickets
        }
    }

    @IBAction func closeAction() {
        self.dismiss(animated: true, completion: nil)
    }
}


extension TicketsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TicketTableViewCell
        cell.setup(ticket: tickets[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tickets.count
    }
}
