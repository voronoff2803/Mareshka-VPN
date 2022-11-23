//
//  QRAuthViewController.swift
//  Mareshka VPN
//
//  Created by Alexey Voronov on 08.11.2022.
//

import UIKit
import QRCode

class QRAuthViewController: UIViewController {
    @IBOutlet weak var qrCodeView: QRCodeView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let doc = QRCode.Document(utf8String: "Hi there!", errorCorrection: .high)
        
        qrCodeView.document = doc
        
        let eyeShape = QRCode.EyeShape.RoundedRect()
        self.qrCodeView.design.shape.eye = eyeShape
        
        let pixelShape = QRCode.PixelShape.RoundedPath(cornerRadiusFraction: 2, hasInnerCorners: true)
        self.qrCodeView.design.shape.onPixels = pixelShape

        qrCodeView.ibBackgroundColor = .clear
        qrCodeView.ibEyeColor = .white
        qrCodeView.ibPixelColor = .white
        qrCodeView.ibPupilColor = .white
    }

}
