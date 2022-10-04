//
//  Configuration.swift
//  StrongVPN
//
//  Created by witworkapp on 12/19/20.
//


import Foundation

class Configuration {
    static let SERVER_KEY = "SERVER_KEY"
    static let ACCOUNT_KEY = "ACCOUNT_KEY"
    static let PASSWORD_KEY = "PASSWORD_KEY"
    static let ONDEMAND_KEY = "ONDEMAND_KEY"
    static let PSK_KEY = "PSK_KEY"
    
    static let KEYCHAIN_PASSWORD_KEY = "KEYCHAIN_PASSWORD_KEY"
    static let KEYCHAIN_PSK_KEY = "KEYCHAIN_PSK_KEY"
    
    public let server: String
    public let account: String
    public let password: String
    public let onDemand: Bool
    public let psk: String?
    public var pskEnabled: Bool {
        return psk != nil
    }
    
    init(server: String, account: String, password: String, onDemand: Bool = false, psk: String? = nil) {
        self.server = server
        self.account = account
        self.password = password
        self.onDemand = onDemand
        self.psk = psk
    }
    
    func getPasswordRef() -> Data? {
        let vpnKeychain = VpnKeychain()
        try? vpnKeychain.setPassword(password, forKey: Configuration.KEYCHAIN_PASSWORD_KEY)
        return vpnKeychain.getPasswordReference(forKey: Configuration.KEYCHAIN_PASSWORD_KEY)
    }
    
    func getPSKRef() -> Data? {
        return nil
    }
    
    static func loadFromDefaults() -> Configuration {
        let def = UserDefaults.standard
        let server = def.string(forKey: Configuration.SERVER_KEY) ?? ""
        let account = def.string(forKey: Configuration.ACCOUNT_KEY) ?? ""
        let password = def.string(forKey: Configuration.PASSWORD_KEY) ?? ""
        let onDemand = def.bool(forKey: Configuration.ONDEMAND_KEY)
        let psk = def.string(forKey: Configuration.PSK_KEY)
        return Configuration(
            server: server,
            account: account,
            password: password,
            onDemand: onDemand,
            psk: psk
        )
    }
    func saveToDefaults() {
        let def = UserDefaults.standard
        def.set(server, forKey: Configuration.SERVER_KEY)
        def.set(account, forKey: Configuration.ACCOUNT_KEY)
        def.set(password, forKey: Configuration.PASSWORD_KEY)
        def.set(onDemand, forKey: Configuration.ONDEMAND_KEY)
        def.set(psk, forKey: Configuration.PSK_KEY)
    }
}
