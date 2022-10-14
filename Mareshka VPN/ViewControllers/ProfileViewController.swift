//
//  ProfileViewController.swift
//  Matreshka VPN
//
//  Created by Alexey Voronov on 24.03.2022.
//

import UIKit
import BLTNBoard
import AuthenticationServices
import GoogleSignIn

class ProfileViewController: RootViewController {
    
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var profileLabelSmall: UILabel!
    @IBOutlet weak var planLabel: UILabel!
    @IBOutlet weak var planSmall: UILabel!
    @IBOutlet weak var expireDate: UILabel!
    @IBOutlet weak var expireDateSmall: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var menuCells = [
        MenuCellModel(title: "scanQR".localized, icon: UIImage(named: "qrIcon")!, color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), handler: {self.showQRscanner()}),
        MenuCellModel(title: "referal".localized, icon: UIImage(named: "refIcon")!, color: #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1), handler: {self.showReferal()}),
        MenuCellModel(title: "subCancel".localized, icon: UIImage(named: "subCancelIcon")!, color: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), handler: {self.cancelSub()}),
        MenuCellModel(title: "deleteAccount".localized, icon: UIImage(named: "trashBinIcon")!, color: #colorLiteral(red: 0.9568627451, green: 0.1882352941, blue: 0.1882352941, alpha: 1), handler: {self.deleteAcc()}),
        MenuCellModel(title: "logout".localized, icon: UIImage(named: "exitIcon")!, color: #colorLiteral(red: 0.7725490196, green: 0.3725490196, blue: 0.8, alpha: 1), handler: {MatreshkaHelper.shared.logout()})
    ]
    
    var filteredMenuCells: [MenuCellModel] {
        menuCells.filter({$0.isEnabled})
    }
    
    var state: ProfileState = .notAuthorized {
        didSet {
            self.button?.backgroundColor = state == .authorized ? UIColor.systemRed.withAlphaComponent(0.08) : UIColor(named: "ColorTint")
            self.button?.borderColor = state == .authorized ? UIColor.systemRed : UIColor.clear
            self.button?.borderWidth = state == .authorized ? 2.0 : 0.0
            self.button?.tintColor = state == .authorized ? UIColor.systemRed : UIColor.white
            
            button?.isHidden = (state == .authorized)
            
            menuCells[4].isEnabled = (state == .authorized)
            menuCells[3].isEnabled = (state == .authorized)
            menuCells[0].isEnabled = (state == .authorized)
        }
    }
    
    lazy var bulletinManager: BLTNItemManager = {
        let page = AuthInBulletinPage(title: "auth".localized)
        
        page.appleButtonAction = { self.appleAuth() }
        page.googleButtonAction = { self.googleAuth() }
        page.emailButtonAction = { self.emailAuth() }
        
        let rootItem: BLTNItem = page
        let manager = BLTNItemManager(rootItem: rootItem)
        manager.backgroundColor = #colorLiteral(red: 0.09678619355, green: 0.1317168474, blue: 0.2372510433, alpha: 1)
        
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        NotificationCenter.default.addObserver(self, selector:#selector(updateProfile), name: .userProfileUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(updateMenuCells), name: .menuCellsUpdate, object: nil)
        
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateProfile()
    }
    
    @objc func updateMenuCells() {
        collectionView.reloadData()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.layoutIfNeeded() // need to call before update collection view layout.
        
        let gridNumber = Int(self.collectionView.bounds.width) / 120
        collectionView.adaptBeautifulGrid(numberOfGridsPerRow: gridNumber, gridLineSpace: 16.0)
    }
    
    func showQRscanner() {
        var configuration = QRScannerConfiguration()
        configuration.galleryImage = nil
        configuration.cameraImage = nil
        configuration.flashOnImage = nil
        configuration.readQRFromPhotos = false
        configuration.hint = "scanQRdescription".localized
        configuration.title = "scanQR".localized
        
        
        let scanner = QRCodeScannerController(qrScannerConfiguration: configuration)
        scanner.view.backgroundColor = UIColor(named: "LoaderColor")
        scanner.delegate = self
        self.present(scanner, animated: true, completion: nil)
    }
    
    @IBAction func cancelSub() {
        MatreshkaHelper.shared.cancelSub()
    }
    
    @IBAction func supportAction() {
        if let url = URL(string: "\(MatreshkaHelper.webDomain)/support") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func deleteAcc() {
        let refreshAlert = UIAlertController(title: "deleteAccount".localized, message: "dataWarning".localized, preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            MatreshkaHelper.shared.removeAccount()
        }))
        refreshAlert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        
        refreshAlert.show()
    }
    
    func setupUI() {
        profileLabel.text = ""
        planLabel.text = ""
        expireDate.text = ""
        button.setTitle("auth".localized, for: .normal)
        profileLabelSmall.text = "profile".localized
        planSmall.text = "currentPlan".localized
        expireDateSmall.text = "endDate".localized
        
    }
    
    func appleAuth() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    func googleAuth() {
        let signInConfig = GIDConfiguration.init(clientID: MatreshkaHelper.googleClientID)
        
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
            guard error == nil else { MatreshkaHelper.shared.showAlert(message: error!.localizedDescription, error: true); return }
            
            let userIdentifier = user?.userID ?? ""
            let email = user?.profile?.email
            
            self.bulletinManager.dismissBulletin()
            MatreshkaHelper.shared.authGoogle(credentials: userIdentifier, email: email ?? "")
        }
    }
    
    func emailAuth() {
        let emailPage = EmailFieldBulletinPage(title: "email".localized)
        
        emailPage.textInputHandler = { email in
            MatreshkaHelper.shared.authMailStart(email: email) { [weak self] error in
                if error == nil {
                    self?.codeAuth()
                } else {
                    self?.bulletinManager.dismissBulletin()
                }
            }
        }
        
        bulletinManager.push(item: emailPage)
        emailPage.emailField.becomeFirstResponder()
    }
    
    func codeAuth() {
        let codePage = CodeBulletinPage(title: "code".localized)
        codePage.descriptionText = "codeInfo".localized
        codePage.textInputHandler = { code in
            MatreshkaHelper.shared.authMailSubmit(code: code) { [weak self] in
                self?.bulletinManager.dismissBulletin()
            }
        }
        
        bulletinManager.push(item: codePage)
        codePage.field.becomeFirstResponder()
    }

    
    @objc func updateProfile() {
        menuCells[1].isEnabled = (MatreshkaHelper.shared.systemGlobalConfig.enablePromos ?? false &&
                                   !MatreshkaHelper.shared.isAnonymousUser)
        if MatreshkaHelper.shared.isAnonymousUser {
            if let anonymousUser = MatreshkaHelper.shared.anonymousUser {
                profileLabel.text = "anon".localized
                expireDate.text = anonymousUser.createdAt?.adding(days: 3).toString()
                planLabel.text = "trial".localized
                state = .notAuthorized
                menuCells[2].isEnabled = MatreshkaHelper.shared.isAnonymousUser ? false : true
            }
        } else if let user = MatreshkaHelper.shared.user {
            profileLabel.text = user.email
            state = .authorized

            if let subscription = MatreshkaHelper.shared.subscription {
                expireDate.text = subscription.expiredAt?.toString()
                planLabel.text = subscription.name
                menuCells[2].isEnabled = true
            } else {
                if MatreshkaHelper.shared.isSubscriptionActive() {
                    expireDate.text = user.createdAt?.adding(days: 3).toString()
                    planLabel.text = "trial".localized
                }
                menuCells[2].isEnabled = false
                planLabel.text = "sub not found".localized
                expireDate.text = ""
            }
        } else {
            profileLabel.text = ""
            planLabel.text = ""
            expireDate.text = ""
        }
    }
    
    @objc func buttonAction() {
        print(state == .notAuthorized)
        if state == .notAuthorized {
            bulletinManager.showBulletin(above: self)
        } else {
            MatreshkaHelper.shared.logout()
        }
    }
    
    @objc func showReferal() {
        performSegue(withIdentifier: "referal", sender: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name:  .userProfileUpdate, object: nil)
        NotificationCenter.default.removeObserver(self, name:  .menuCellsUpdate, object: nil)
    }
}


extension ProfileViewController: ASAuthorizationControllerDelegate {
    var appleEmail: String {
        get {
            return UserDefaults.standard.string(forKey: "appleEmail") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "appleEmail")
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            var email = appleIDCredential.email
            
            guard let data = appleIDCredential.authorizationCode else { return }
            guard let authCode = String(data: data, encoding: .utf8) else { return }
            
            if email == nil {
                email = appleEmail
            } else {
                appleEmail = email!
            }
            
            bulletinManager.dismissBulletin()
            MatreshkaHelper.shared.authApple(credentials: userIdentifier, email: email ?? "", authorizationCode: authCode)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        MatreshkaHelper.shared.showAlert(message: error.localizedDescription, error: true)
    }
}


enum ProfileState {
    case authorized
    case notAuthorized
}


extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredMenuCells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MenuCollectionViewCell
        let model = filteredMenuCells[indexPath.row]
        cell.setup(model: model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = filteredMenuCells[indexPath.row]
        model.handler()
    }
}


struct MenuCellModel {
    var isEnabled: Bool = false {
        didSet {
            NotificationCenter.default.post(name: .menuCellsUpdate, object: nil)
        }
    }
    let title: String
    let icon: UIImage
    let color: UIColor
    let handler: () -> ()
}


extension ProfileViewController: QRScannerCodeDelegate {
    func qrScanner(_ controller: UIViewController, scanDidComplete result: String) {
        if let data = result.data(using: .utf8) {
            do {
                let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
                MatreshkaHelper.shared.submitQR(qrData: dict?["qrAuthId"] ?? "")
            } catch {
                print(error.localizedDescription)
            }
        }
        
        
    }
    
    func qrScannerDidFail(_ controller: UIViewController, error: QRCodeError) {
        print(#function)
    }
    
    func qrScannerDidCancel(_ controller: UIViewController) {
        print(#function)
    }
}
