//
//  ServersViewController.swift
//  Matreshka VPN
//
//  Created by Alexey Voronov on 26.03.2022.
//

import UIKit

class ServersViewController: RootViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var sortedServers: [ServerDTO] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        sortedServers = MatreshkaHelper.shared.serversList.sorted(by: {$0.ping ?? 0 < $1.ping ?? 0})
        
        tableView.reloadData()
        
        navigationItem.title = "servers".localized
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        sortedServers = MatreshkaHelper.shared.serversList.sorted(by: {$0.ping ?? 0 < $1.ping ?? 0})
        
        tableView.reloadData()
    }
}


extension ServersViewController: UITableViewDelegate {
    
}

extension ServersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedServers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ServerCell
        let server = sortedServers[indexPath.row]
        
        cell.setup(server: server)
        
        return cell
    }
    
    
}
