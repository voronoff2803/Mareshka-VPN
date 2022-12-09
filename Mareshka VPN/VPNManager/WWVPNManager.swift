//
//  WWVPNManager.swift
//  StrongVPN
//
//  Created by witworkapp on 12/19/20.
//

import Foundation
import NetworkExtension

final class WWVPNManager: NSObject {
    static let shared: WWVPNManager = {
        let instance = WWVPNManager()
        instance.manager.localizedDescription = Bundle.main.infoDictionary![kCFBundleNameKey as String] as? String
        instance.loadProfile(callback: nil)
        return instance
    }()
    
    let manager: NEVPNManager = { NEVPNManager.shared() }()
    public var isDisconnected: Bool {
        get {
            return (status == .disconnected)
                || (status == .reasserting)
                || (status == .invalid)
        }
    }
    public var status: NEVPNStatus { get { return manager.connection.status } }
    public let statusEvent = Subject<NEVPNStatus>()
    
    private override init() {
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(WWVPNManager.VPNStatusDidChange(_:)),
            name: NSNotification.Name.NEVPNStatusDidChange,
            object: nil)
    }
    public func disconnect(completionHandler: (()->Void)? = nil) {
        manager.onDemandRules = []
        manager.isOnDemandEnabled = false
        manager.saveToPreferences { _ in
            self.manager.connection.stopVPNTunnel()
            completionHandler?()
        }
    }
    
    @objc private func VPNStatusDidChange(_: NSNotification?){
        statusEvent.notify(status)
    }
    private func loadProfile(callback: ((String?)->Void)?) {
        manager.protocolConfiguration = nil
        manager.loadFromPreferences { error in
            if let error = error {
                callback?("Failed to load preferences: \(error.localizedDescription)")
            } else {
                callback?(nil)
            }
        }
    }
    private func saveProfile(callback: ((String?)->Void)?) {
        manager.saveToPreferences { error in
            if let error = error {
                callback?("Failed to load preferences: \(error.localizedDescription)")
            } else {
                callback?(nil)
            }
        }
    }
    public func connectIKEv2(config: Configuration, onError: @escaping (String)->Void) {
        let p = NEVPNProtocolIKEv2()
        
        p.authenticationMethod = .none
        
        p.serverAddress = config.server
        p.disconnectOnSleep = false
        p.deadPeerDetectionRate = NEVPNIKEv2DeadPeerDetectionRate.medium
        p.username = config.account
        p.passwordReference = config.getPasswordRef()
        
        p.sharedSecretReference = config.getPSKRef() // JgbpltnM12#
        p.disableMOBIKE = false
        p.disableRedirect = false
        p.enableRevocationCheck = false
        p.enablePFS = false
        p.useExtendedAuthentication = true
        p.useConfigurationAttributeInternalIPSubnet = false
        
        // two lines bellow may depend of your server configuration
        p.remoteIdentifier = config.server
        p.localIdentifier = config.server
        
        loadProfile { error in
            self.manager.protocolConfiguration = p

            if let error = error {
                onError(error)
            }
//            let evaluationRule = NEEvaluateConnectionRule(matchDomains: TLDList.tlds,
//                                                          andAction: NEEvaluateConnectionRuleAction.connectIfNeeded)
//            evaluationRule.useDNSServers = ["8.8.8.8"]
//            let onDemandRule = NEOnDemandRuleEvaluateConnection()
//            onDemandRule.interfaceTypeMatch = NEOnDemandRuleInterfaceType.any
//            onDemandRule.connectionRules = [evaluationRule]
            
            self.manager.isOnDemandEnabled = true
            self.manager.onDemandRules = [NEOnDemandRuleConnect()]
                
            self.manager.isEnabled = true
            self.saveProfile { error in
                if let error = error {
                    onError(error)
                    return
                }
                self.loadProfile() { error in
                    if let error = error {
                        onError(error)
                        return
                    }
                    self.startVPNTunnel() { error in
                        onError(error)
                    }
                }
            }
        }
    }
    
    private func startVPNTunnel(onError: @escaping (String) -> Void) {
        do {
            try self.manager.connection.startVPNTunnel()
        } catch NEVPNError.configurationInvalid {
            onError("Failed to start tunnel (configuration invalid)")
        } catch NEVPNError.configurationDisabled {
            onError("Failed to start tunnel (configuration disabled)")
        } catch {
            onError("Failed to start tunnel (other error)")
        }
    }
}
