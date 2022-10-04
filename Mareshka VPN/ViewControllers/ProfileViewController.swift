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
//    @IBOutlet weak var referalButton: UIButton!
//    @IBOutlet weak var subCancelButton: UIButton!
//    @IBOutlet weak var deleteButton: UIButton!
    
    var state: ProfileState = .notAuthorized {
        didSet {
            self.button?.backgroundColor = state == .authorized ? UIColor.systemRed.withAlphaComponent(0.08) : UIColor(named: "ColorTint")
            self.button?.borderColor = state == .authorized ? UIColor.systemRed : UIColor.clear
            self.button?.borderWidth = state == .authorized ? 2.0 : 0.0
            self.button?.tintColor = state == .authorized ? UIColor.systemRed : UIColor.white
            
            button?.setTitle(state == .authorized ? "logout".localized : "auth".localized, for: .normal)
            //deleteButton.isHidden = state == .authorized ? false : true
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
        
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        //referalButton.addTarget(self, action: #selector(showReferal), for: .touchUpInside)
        
        //referalButton.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateProfile()
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
        //referalButton.setTitle("referal".localized, for: .normal)
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
//        referalButton.isHidden = !(MatreshkaHelper.shared.systemGlobalConfig.enablePromos ?? false &&
//                                   !MatreshkaHelper.shared.isAnonymousUser)
//        if MatreshkaHelper.shared.isAnonymousUser {
//            if let anonymousUser = MatreshkaHelper.shared.anonymousUser {
//                profileLabel.text = "anon".localized
//                expireDate.text = anonymousUser.createdAt?.adding(days: 3).toString()
//                planLabel.text = "trial".localized
//                state = .notAuthorized
//                subCancelButton.isHidden = MatreshkaHelper.shared.isAnonymousUser ? true : false
//            }
//        } else if let user = MatreshkaHelper.shared.user {
//            profileLabel.text = user.email
//            state = .authorized
//
//            if let subscription = MatreshkaHelper.shared.subscription {
//                expireDate.text = subscription.expiredAt?.toString()
//                planLabel.text = subscription.name
//                subCancelButton.isHidden = false
//            } else {
//                if MatreshkaHelper.shared.isSubscriptionActive() {
//                    expireDate.text = user.createdAt?.adding(days: 3).toString()
//                    planLabel.text = "trial".localized
//                }
//                subCancelButton.isHidden = true
//                planLabel.text = "sub not found".localized
//                expireDate.text = ""
//            }
//        } else {
//            profileLabel.text = ""
//            planLabel.text = ""
//            expireDate.text = ""
//        }
    }
    
    @objc func buttonAction() {
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
