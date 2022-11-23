//
//  ReferalViewController.swift
//  Matreshka VPN
//
//  Created by Alexey Voronov on 17.04.2022.
//

import UIKit
import SPIndicator
import BLTNBoard
import FirebaseAnalytics

class ReferalViewController: UIViewController {
    
    @IBOutlet weak var promoLabel: UILabel!
    @IBOutlet weak var buttonCreateTicket: UIButton!
    @IBOutlet weak var buttonTicketHistory: UIButton!
    @IBOutlet weak var tariffsStackView: UIStackView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var dicountLabel: UILabel!
    @IBOutlet weak var dicountDescriptionLabel: UILabel!
    @IBOutlet weak var promocodeLabel: UILabel!
    
    var tariffs: [TariffDTO] = [] {
        didSet {
            updateUITariffs()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector:#selector(updateUIProfile), name: .userProfileUpdate, object: nil)
        
        updateUIProfile()
        
        MatreshkaHelper.shared.loadProfile()
        
        FirebaseAnalytics.Analytics.logEvent("сlick_referral", parameters: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    lazy var bulletinManager: BLTNItemManager = {
        let page = CreateTicketBulletinPage(title: "withdrawRequest".localized)
        
        let rootItem: BLTNItem = page
        let manager = BLTNItemManager(rootItem: rootItem)
        manager.backgroundColor = #colorLiteral(red: 0.09678619355, green: 0.1317168474, blue: 0.2372510433, alpha: 1)
        
        return manager
    }()
    
    @objc func updateUIProfile() {
        buttonCreateTicket.isHidden = !(MatreshkaHelper.shared.user?.primaryReferral ?? false)
        buttonTicketHistory.isHidden = !(MatreshkaHelper.shared.user?.primaryReferral ?? false)
        
        MatreshkaHelper.shared.getBonusTariffs() { tariff in
            self.tariffs = tariff
        }
        
        let balance = Int(MatreshkaHelper.shared.user?.balance ?? 0.0)
        balanceLabel.text = "points".localized(balance)
        dicountLabel.text = String(MatreshkaHelper.shared.user?.personalPromocodeDiscount == 0 ?
                                   MatreshkaHelper.shared.systemGlobalConfig.discount ?? 0 :
                                    MatreshkaHelper.shared.user?.personalPromocodeDiscount ?? 0) + "%"
        
        let earnCount = MatreshkaHelper.shared.user?.personalPromocodeOwnerBallEarn == 0 ?
                        MatreshkaHelper.shared.systemGlobalConfig.promocodeOwnerBallEarn ?? 0 :
                        MatreshkaHelper.shared.user?.personalPromocodeOwnerBallEarn ?? 0
        
        dicountDescriptionLabel.text = "discountDescription".localized(earnCount)
        promoLabel.text = MatreshkaHelper.shared.user?.promocode?.uppercased() ?? " "
    }
    
    func updateUITariffs() {
        let balance = Int(MatreshkaHelper.shared.user?.balance ?? 0.0)
        tariffsStackView.arrangedSubviews.forEach({if $0 is BonusTariffView { $0.removeFromSuperview() }})
        tariffs.sorted(by: {$0.ballCost ?? 0 < $1.ballCost ?? 0}).forEach({tariff in
            let tariffView = BonusTariffView()
            tariffView.delegate = self
            tariffView.setup(tariff: tariff, balance: Int(balance))
            tariffsStackView.addArrangedSubview(tariffView)
        })
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name:  .userProfileUpdate, object: nil)
    }
    
    @IBAction func copyAction() {
        SPIndicator.present(title: "copyAlert".localized, preset: .done)
        UIPasteboard.general.string = promoLabel.text
        
        FirebaseAnalytics.Analytics.logEvent("copy_refferal", parameters: nil)
    }
    
    @IBAction func closeAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createTicketAction() {
        bulletinManager.showBulletin(in: UIApplication.shared)
    }
}


extension ReferalViewController: BonusTariffViewDelegate {
    func tariffSelectAction(id: String) {
        MatreshkaHelper.shared.buySubscriptionScore(id: id) { result in
            MatreshkaHelper.shared.showAlert(message: "sucessBuy".localized, error: false)
            MatreshkaHelper.shared.loadProfile()
            self.updateUITariffs()
        }
    }
}
