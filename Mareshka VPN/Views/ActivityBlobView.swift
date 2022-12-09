//
//  ActivityBlobView.swift
//  Test
//
//  Created by Alexey Voronov on 08.12.2022.
//

import UIKit
import SceneKit


class ActivityBlobView: SCNView {
    enum State {
        case disconnected
        case loading
        case connected
    }
    
    init() {
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    func setup() {
        self.preferredFramesPerSecond = 30
        
        self.scene = blobScene
        self.layer.compositingFilter = "screenBlendMode"
        
        self.isPlaying = true
        self.antialiasingMode = .none
        
        sphereNode.geometry!.firstMaterial!.diffuse.contents = UIColor(red: 0.83, green: 0.84, blue: 0.71, alpha: 1.0)
        
        backgroundColor = .black
        
        state = .disconnected
    }
    
    lazy var sphereNode: SCNNode = {
        blobScene.rootNode.childNode(withName: "sphere", recursively: false)!
    }()
    
    let blobScene = SCNScene(named: "BlobScene.scn")!
    
    var state: State = .disconnected {
        didSet {
            switch state {
            case .connected:
                setValue(red: 0.86, green: 0.81, blue: 0.71)
            case .loading:
                setValue(red: 0.86, green: 0.86, blue: 0.79)
            case .disconnected:
                setValue(red: 0.86, green: 0.77, blue: 0.83)
            }
        }
    }
    
    func setValue(red: CGFloat, green: CGFloat, blue: CGFloat) {
        sphereNode.removeAction(forKey: "mainAction")
        
        let changeColor = SCNAction.customAction(duration: 5) { (node, elapsedTime) -> () in
            
            let currentColor = node.geometry?.firstMaterial?.diffuse.contents as! UIColor
            let diffR = currentColor.rgba!.red - red
            let diffG = currentColor.rgba!.green - green
            let diffB = currentColor.rgba!.blue - blue
            
            let newColor = UIColor(red: currentColor.rgba!.red - diffR * 0.16,
                                   green: currentColor.rgba!.green - diffG * 0.10,
                                   blue: currentColor.rgba!.blue - diffB * 0.10,
                                   alpha: 1)
            
            node.geometry!.firstMaterial!.diffuse.contents = newColor
        }
        
        sphereNode.runAction(changeColor, forKey: "mainAction")
    }
    
    func setOnTap(isTap: Bool) {
        let changeColor = SCNAction.customAction(duration: 1) { (node, elapsedTime) -> () in
            
            let currentColor = node.geometry?.firstMaterial?.diffuse.contents as! UIColor
            let diffR = currentColor.rgba!.red - (isTap ? 0.91 : 0.86)
            
            let newColor = UIColor(red: currentColor.rgba!.red - diffR * 0.1,
                                   green: currentColor.rgba!.green,
                                   blue: currentColor.rgba!.blue,
                                   alpha: 1)
            
            node.geometry!.firstMaterial!.diffuse.contents = newColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (isTap ? 0.0 : 0.1)) { [weak self] in
            self?.sphereNode.removeAction(forKey: "tapAction")
            self?.sphereNode.runAction(changeColor, forKey: "tapAction")
        }
    }
}
