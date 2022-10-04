//
//  ViewController.swift
//  TestMac
//
//  Created by Alexey Voronov on 06.09.2022.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bundleFileName = "MacPlugin.bundle"
        guard let bundleURL = Bundle.main.builtInPlugInsURL?
                                    .appendingPathComponent(bundleFileName) else { return }

        /// 2. Create a bundle instance with the plugin URL
        guard let bundle = Bundle(url: bundleURL) else { return }

        /// 3. Load the bundle and our plugin class
        let className = "MacPlugin.MacPlugin"
        guard let pluginClass = bundle.classNamed(className) as? Plugin.Type else { return }

        /// 4. Create an instance of the plugin class
        let plugin = pluginClass.init()
        plugin.startVPN()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

