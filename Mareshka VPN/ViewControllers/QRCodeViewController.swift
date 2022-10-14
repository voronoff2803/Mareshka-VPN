//
//  QRCodeViewController.swift
//  Mareshka VPN
//
//  Created by Alexey Voronov on 14.10.2022.
//

import UIKit
import PhotosUI
import CoreGraphics
import AVFoundation


public struct QRScannerConfiguration {
    public var title: String
    public var hint: String?
    public var invalidQRCodeAlertTitle: String
    public var invalidQRCodeAlertActionTitle: String
    public var uploadFromPhotosTitle: String
    public var cameraImage: UIImage?
    public var flashOnImage: UIImage?
    public var galleryImage: UIImage?
    public var length: CGFloat
    public var color: UIColor
    public var radius: CGFloat
    public var thickness: CGFloat
    public var readQRFromPhotos: Bool
    public var cancelButtonTitle: String
    public var cancelButtonTintColor: UIColor?
    
    public init(title: String = "Scan QR Code",
                hint: String = "Align QR code within frame to scan",
                uploadFromPhotosTitle: String = "Upload from photos",
                invalidQRCodeAlertTitle: String = "Invalid QR Code",
                invalidQRCodeAlertActionTitle: String = "OK",
                cameraImage: UIImage? = nil,
                flashOnImage: UIImage? = nil,
                length: CGFloat = 20.0,
                color: UIColor = .green,
                radius: CGFloat = 10.0,
                thickness: CGFloat = 5.0,
                readQRFromPhotos: Bool = true,
                cancelButtonTitle: String = "Cancel",
                cancelButtonTintColor: UIColor? = nil) {
        self.title = title
        self.hint = hint
        self.uploadFromPhotosTitle = uploadFromPhotosTitle
        self.invalidQRCodeAlertTitle = invalidQRCodeAlertTitle
        self.invalidQRCodeAlertActionTitle = invalidQRCodeAlertActionTitle
        self.cameraImage = cameraImage
        self.flashOnImage = flashOnImage
        self.length = length
        self.color = color
        self.radius = radius
        self.thickness = thickness
        self.readQRFromPhotos = readQRFromPhotos
        self.cancelButtonTitle = cancelButtonTitle
        self.cancelButtonTintColor = cancelButtonTintColor
    }
}

extension QRScannerConfiguration {
    public static var `default`: QRScannerConfiguration {
        QRScannerConfiguration(title: "Scan QR Code",
                               hint: "Align QR code within frame to scan",
                               uploadFromPhotosTitle: "Upload from photos",
                               invalidQRCodeAlertTitle: "Invalid QR Code",
                               invalidQRCodeAlertActionTitle: "OK",
                               cameraImage: nil,
                               flashOnImage: nil,
                               length: 20.0,
                               color: .green,
                               radius: 10.0,
                               thickness: 5.0,
                               readQRFromPhotos: true,
                               cancelButtonTitle: "Cancel",
                               cancelButtonTintColor: nil)
    }
}


public protocol ImagePickerDelegate: AnyObject {
    func didSelect(image: UIImage?)
}


class PhotoPicker: NSObject {
    
    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?
    
    public init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        
        self.pickerController = UIImagePickerController()
        super.init()
        self.presentationController = presentationController
        self.delegate = delegate
        self.pickerController.delegate = self
        self.pickerController.allowsEditing = false
        
    }
    
    public func present(from sourceView: UIView) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraRollAction = UIAlertAction(title: "Camera roll", style: .default) { [unowned self] _ in
            self.pickerController.sourceType = .savedPhotosAlbum
            presentationController?.present(self.pickerController, animated: true)
        }
        let photoLibraryAction = UIAlertAction(title: "Photo library", style: .default) { [unowned self] _ in
            self.pickerController.sourceType = .photoLibrary
            presentationController?.present(self.pickerController, animated: true)
        }
        [cameraRollAction, photoLibraryAction].forEach { action in
            alertController.addAction(action)
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }
        self.presentationController?.present(alertController, animated: true)
    }
    
    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)
        self.delegate?.didSelect(image: image)
    }
}

extension PhotoPicker: UIImagePickerControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        self.pickerController(picker, didSelect: image)
    }
}

extension PhotoPicker: UINavigationControllerDelegate {}

@available(iOS 14, *)
extension PHPhotoPicker: UINavigationControllerDelegate{}

@available(iOS 14, *)
class PHPhotoPicker: NSObject {
    private let pickerController: PHPickerViewController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?
    
    public init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        var phPickerConfiguration = PHPickerConfiguration(photoLibrary: .shared())
        phPickerConfiguration.selectionLimit = 1
        phPickerConfiguration.filter = .images
        self.pickerController = PHPickerViewController(configuration: phPickerConfiguration)
        super.init()
        self.pickerController.delegate = self
        self.presentationController = presentationController
        self.delegate = delegate
    }
    
    public func present() {
        PHPhotoLibrary.requestAuthorization({
            (newStatus) in
            DispatchQueue.main.async {
                if newStatus ==  PHAuthorizationStatus.authorized {
                    
                    self.presentationController?.present(self.pickerController, animated: true)
                }
            }
        })
    }
    
}

@available(iOS 14, *)
extension PHPhotoPicker: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (object, error) in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self.delegate?.didSelect(image: image)
                    }
                }
            })
        }
    }
    
}


public enum QRCodeError: Error {
    case inputFailed
    case outoutFailed
    case emptyResult
}

extension QRCodeError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .inputFailed:
            return "Failed to add input."
        case .outoutFailed:
            return "Failed to add output."
        case .emptyResult:
            return "Empty string found."
        }
    }
}

extension QRCodeError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .inputFailed:
            return NSLocalizedString(
                "Failed to add input.",
                comment: "Failed to add input."
            )
        case .outoutFailed:
            return NSLocalizedString(
                "Failed to add output.",
                comment: "Failed to add output."
            )
        case .emptyResult:
            return NSLocalizedString(
                "Empty string found.",
                comment: "Empty string found."
            )
        }
    }
}


open class QRScannerFrame: UIView {
    
    var length: CGFloat = 25.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var color: UIColor = .green {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var radius: CGFloat = 10.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var thickness: CGFloat = 5.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        color.set()
        
        let XAdjustment = thickness / 2
        let path = UIBezierPath()
        
        // Top left
        path.move(to: CGPoint(x: XAdjustment, y: length + radius + XAdjustment))
        path.addLine(to: CGPoint(x: XAdjustment, y: radius + XAdjustment))
        path.addArc(withCenter: CGPoint(x: radius + XAdjustment, y: radius + XAdjustment), radius: radius, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 3 / 2, clockwise: true)
        path.addLine(to: CGPoint(x: length + radius + XAdjustment, y: XAdjustment))
        
        // Top right
        path.move(to: CGPoint(x: frame.width - XAdjustment, y: length + radius + XAdjustment))
        path.addLine(to: CGPoint(x: frame.width - XAdjustment, y: radius + XAdjustment))
        path.addArc(withCenter: CGPoint(x: frame.width - radius - XAdjustment, y: radius + XAdjustment), radius: radius, startAngle: 0, endAngle: CGFloat.pi * 3 / 2, clockwise: false)
        path.addLine(to: CGPoint(x: frame.width - length - radius - XAdjustment, y: XAdjustment))
        
        // Bottom left
        path.move(to: CGPoint(x: XAdjustment, y: frame.height - length - radius - XAdjustment))
        path.addLine(to: CGPoint(x: XAdjustment, y: frame.height - radius - XAdjustment))
        path.addArc(withCenter: CGPoint(x: radius + XAdjustment, y: frame.height - radius - XAdjustment), radius: radius, startAngle: CGFloat.pi, endAngle: CGFloat.pi / 2, clockwise: false)
        path.addLine(to: CGPoint(x: length + radius + XAdjustment, y: frame.height - XAdjustment))
        
        // Bottom right
        path.move(to: CGPoint(x: frame.width - XAdjustment, y: frame.height - length - radius - XAdjustment))
        path.addLine(to: CGPoint(x: frame.width - XAdjustment, y: frame.height - radius - XAdjustment))
        path.addArc(withCenter: CGPoint(x: frame.width - radius - XAdjustment, y: frame.height - radius - XAdjustment), radius: radius, startAngle: 0, endAngle: CGFloat.pi / 2, clockwise: true)
        path.addLine(to: CGPoint(x: frame.width - length - radius - XAdjustment, y: frame.height - XAdjustment))
        
        path.lineWidth = thickness
        path.stroke()
    }
    
}


class RoundButton: UIButton {
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    
    func setup() {
        self.frame = frame
        self.tintColor = UIColor.white
        self.layer.cornerRadius = frame.size.height/2
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.contentMode = .scaleAspectFit
    }
}



public class QRCodeScannerController: UIViewController,
                                      AVCaptureMetadataOutputObjectsDelegate,
                                      UIImagePickerControllerDelegate,
                                      UINavigationBarDelegate {
    
    public weak var delegate: QRScannerCodeDelegate?
    public var qrScannerConfiguration: QRScannerConfiguration
    private var flashButton: UIButton?
    
    //Default Properties
    private let spaceFactor: CGFloat = 16.0
    private let devicePosition: AVCaptureDevice.Position = .back
    private var _delayCount: Int = 0
    private let delayCount: Int = 15
    private let roundButtonHeight: CGFloat = 50.0
    private let roundButtonWidth: CGFloat = 50.0
    var photoPicker: NSObject?
    
    //Initialise CaptureDevice
    private lazy var defaultDevice: AVCaptureDevice? = {
        if let device = AVCaptureDevice.default(for: .video) {
            return device
        }
        return nil
    }()
    
    //Initialise front CaptureDevice
    private lazy var frontDevice: AVCaptureDevice? = {
        if #available(iOS 10, *) {
            if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                return device
            }
        } else {
            for device in AVCaptureDevice.devices(for: .video) {
                if device.position == .front { return device }
            }
        }
        return nil
    }()
    
    //Initialise AVCaptureInput with defaultDevice
    private lazy var defaultCaptureInput: AVCaptureInput? = {
        if let captureDevice = defaultDevice {
            do {
                return try AVCaptureDeviceInput(device: captureDevice)
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }()
    
    //Initialise AVCaptureInput with frontDevice
    private lazy var frontCaptureInput: AVCaptureInput?  = {
        if let captureDevice = frontDevice {
            do {
                return try AVCaptureDeviceInput(device: captureDevice)
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }()
    
    private let dataOutput = AVCaptureMetadataOutput()
    private let captureSession = AVCaptureSession()
    
    //Initialise videoPreviewLayer with capture session
    private lazy var videoPreviewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        layer.cornerRadius = 10.0
        return layer
    }()
    
    public init(qrScannerConfiguration: QRScannerConfiguration = .default) {
        
        self.qrScannerConfiguration = qrScannerConfiguration
        super.init(nibName: nil, bundle: nil)
        if #available(iOS 14, *) {
            photoPicker = PHPhotoPicker(presentationController: self, delegate: self) as PHPhotoPicker
        } else {
            photoPicker = PhotoPicker(presentationController: self, delegate: self) as PhotoPicker
        }
    }
    
    required convenience init?(coder: NSCoder) {
        self.init()
    }
    
    deinit {
        print("SwiftQRScanner deallocating...")
    }
    
    //MARK: Life cycle methods
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        navigationBar.prefersLargeTitles = false
        navigationBar.tintColor = .white
        navigationBar.shadowImage = UIImage()
        navigationBar.barTintColor = UIColor(named: "LoaderColor")
        navigationBar.backgroundColor = UIColor(named: "LoaderColor")
        navigationBar.setBackgroundImage(nil, for: .default)
        navigationBar.isTranslucent = false
        
        
        view.addSubview(navigationBar)
        
        let title = UINavigationItem(title: qrScannerConfiguration.title)
        let cancelBarButton = UIBarButtonItem(title: qrScannerConfiguration.cancelButtonTitle,
                                     style: .plain,
                                     target: self,
                                     action: #selector(dismissVC))
        if let tintColor = qrScannerConfiguration.cancelButtonTintColor {
            cancelBarButton.tintColor = tintColor
        }
        title.leftBarButtonItem = cancelBarButton
        navigationBar.setItems([title], animated: false)
        self.presentationController?.delegate = self
        
        //Currently only "Portraint" mode is supported
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        _delayCount = 0
        prepareQRScannerView()
        startScanningQRCode()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addButtons()
    }
    
    /** This calls up methods which makes code ready for scan codes.
     - parameter view: UIView in which you want to add scanner.
     */
    private func prepareQRScannerView() {
        setupCaptureSession(devicePosition) //Default device capture position is rear
        addViedoPreviewLayer()
        addRoundCornerFrame()
    }
    
    //Creates corner rectagle frame with green coloe(default color)
    private func addRoundCornerFrame() {
        let width: CGFloat = self.view.frame.size.width / 1.5
        let height: CGFloat = self.view.frame.size.height / 2
        let roundViewFrame = CGRect(origin: CGPoint(x: self.view.frame.midX - width/2,
                                                    y: self.view.frame.midY - height/2),
                                    size: CGSize(width: width, height: width))
        self.view.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        let qrFramedView = QRScannerFrame(frame: roundViewFrame)
        qrFramedView.thickness = qrScannerConfiguration.thickness
        qrFramedView.length = qrScannerConfiguration.length
        qrFramedView.radius = qrScannerConfiguration.radius
        qrFramedView.color = qrScannerConfiguration.color
        qrFramedView.autoresizingMask = UIView.AutoresizingMask(rawValue: UInt(0.0))
        self.view.addSubview(qrFramedView)
        if qrScannerConfiguration.readQRFromPhotos {
            addPhotoPickerButton(frame: CGRect(origin: CGPoint(x: self.view.frame.midX - width/2,
                                                               y: roundViewFrame.origin.y + width + 30),
                                               size: CGSize(width: self.view.frame.size.width/2.2, height: 36)))
        }
        
    }
    
    private func addPhotoPickerButton(frame: CGRect) {
        let photoPickerButton = UIButton(frame: frame)
        let buttonAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.black]
        let attributedTitle = NSMutableAttributedString(string: qrScannerConfiguration.uploadFromPhotosTitle, attributes: buttonAttributes)
        photoPickerButton.setAttributedTitle(attributedTitle, for: .normal)
        photoPickerButton.center.x = self.view.center.x
        photoPickerButton.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        photoPickerButton.layer.cornerRadius = 18
        if let galleryImage = qrScannerConfiguration.galleryImage {
            photoPickerButton.setImage(galleryImage, for: .normal)
            photoPickerButton.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
            photoPickerButton.titleEdgeInsets.left = 10
        }
        photoPickerButton.addTarget(self, action: #selector(showImagePicker), for: .touchUpInside)
        self.view.addSubview(photoPickerButton)
    }
    
    
    @objc private func showImagePicker() {
        if #available(iOS 14, *) {
            if let picker = photoPicker as? PHPhotoPicker {
                picker.present()
            }
        } else {
            if let picker = photoPicker as? PhotoPicker {
                picker.present(from: self.view)
            }
        }
        
    }
    
    // Adds buttons to view which can we used as extra fearures
    private func addButtons() {
        
        //Torch button
        if let flashOffImg = qrScannerConfiguration.flashOnImage {
            flashButton = RoundButton(frame: CGRect(x: 32, y: self.view.frame.height-100, width: roundButtonWidth, height: roundButtonHeight))
            flashButton!.addTarget(self, action: #selector(toggleTorch), for: .touchUpInside)
            flashButton!.setImage(flashOffImg, for: .normal)
            view.addSubview(flashButton!)
        }
        
        //Camera button
        if let cameraImg = qrScannerConfiguration.cameraImage {
            let cameraSwitchButton = RoundButton(frame: CGRect(x: self.view.bounds.width - (roundButtonWidth + 32), y: self.view.frame.height-100, width: roundButtonWidth, height: roundButtonHeight))
            cameraSwitchButton.setImage(cameraImg, for: .normal)
            cameraSwitchButton.addTarget(self, action: #selector(switchCamera), for: .touchUpInside)
            view.addSubview(cameraSwitchButton)
        }
    }
    
    //Toggle torch
    @objc private func toggleTorch() {
        //If device postion is front then no need to torch
        if let currentInput = getCurrentInput() {
            if currentInput.device.position == .front { return }
        }
        
        guard  let defaultDevice = defaultDevice else {return}
        if defaultDevice.isTorchAvailable {
            do {
                try defaultDevice.lockForConfiguration()
                defaultDevice.torchMode = defaultDevice.torchMode == .on ? .off : .on
                flashButton?.backgroundColor = defaultDevice.torchMode == .on ? UIColor.white.withAlphaComponent(0.3) : UIColor.black.withAlphaComponent(0.5)
                defaultDevice.unlockForConfiguration()
            } catch let error as NSError {
                print(error)
            }
        }
    }
    
    //Switch camera
    @objc private func switchCamera() {
        if let frontDeviceInput = frontCaptureInput {
            captureSession.beginConfiguration()
            if let currentInput = getCurrentInput() {
                captureSession.removeInput(currentInput)
                let newDeviceInput = (currentInput.device.position == .front) ? defaultCaptureInput : frontDeviceInput
                captureSession.addInput(newDeviceInput!)
            }
            captureSession.commitConfiguration()
        }
    }
    
    private func getCurrentInput() -> AVCaptureDeviceInput? {
        if let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput {
            return currentInput
        }
        return nil
    }
    
    @objc private func dismissVC() {
        self.dismiss(animated: true, completion: nil)
        delegate?.qrScannerDidCancel(self)
    }
    
    //MARK: - Setup and start capturing session
    
    private func startScanningQRCode() {
        if captureSession.isRunning { return }
        captureSession.startRunning()
    }
    
    private func setupCaptureSession(_ devicePostion: AVCaptureDevice.Position) {
        if captureSession.isRunning { return }
        switch devicePosition {
        case .front:
            if let frontDeviceInput = frontCaptureInput {
                if !captureSession.canAddInput(frontDeviceInput) {
                    delegate?.qrScannerDidFail(self, error: .inputFailed)
                    self.dismiss(animated: true, completion: nil)
                    return
                }
                captureSession.addInput(frontDeviceInput)
            }
        case .back, .unspecified :
            if let defaultDeviceInput = defaultCaptureInput {
                if !captureSession.canAddInput(defaultDeviceInput) {
                    delegate?.qrScannerDidFail(self, error: .inputFailed)
                    self.dismiss(animated: true, completion: nil)
                    return
                }
                captureSession.addInput(defaultDeviceInput)
            }
        default: print("Do nothing")
        }
        
        if !captureSession.canAddOutput(dataOutput) {
            delegate?.qrScannerDidFail(self, error: .outoutFailed)
            self.dismiss(animated: true, completion: nil)
            return
        }
        captureSession.addOutput(dataOutput)
        dataOutput.metadataObjectTypes = dataOutput.availableMetadataObjectTypes
        dataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
    }
    
    //Inserts layer to view
    private func addViedoPreviewLayer() {
        videoPreviewLayer.frame = CGRect(x: view.bounds.origin.x,
                                         y: view.bounds.origin.y,
                                         width: view.bounds.size.width,
                                         height: view.bounds.size.height)
        view.layer.insertSublayer(videoPreviewLayer, at: 0)
        addMaskToVideoPreviewLayer()
    }
    
    // This method get called when Scanning gets complete
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for data in metadataObjects {
            let transformed = videoPreviewLayer.transformedMetadataObject(for: data) as? AVMetadataMachineReadableCodeObject
            if let unwraped = transformed {
                if view.bounds.contains(unwraped.bounds) {
                    _delayCount = _delayCount + 1
                    if _delayCount > delayCount {
                        if let unwrapedStringValue = unwraped.stringValue {
                            delegate?.qrScanner(self, scanDidComplete: unwrapedStringValue)
                        } else {
                            delegate?.qrScannerDidFail(self, error: .emptyResult)
                        }
                        captureSession.stopRunning()
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

extension QRCodeScannerController: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidDismiss( _ presentationController: UIPresentationController) {
        self.delegate?.qrScannerDidCancel(self)
    }
}

extension QRCodeScannerController: ImagePickerDelegate {
    public func didSelect(image: UIImage?) {
        if let selectedImage = image, let qrCodeData = selectedImage.parseQR() {
            if(qrCodeData.isEmpty) {
                showInvalidQRCodeAlert()
                return
            }
            self.delegate?.qrScanner(self, scanDidComplete: qrCodeData)
            self.dismiss(animated: true)
        } else {
            showInvalidQRCodeAlert()
        }
    }
    
    private func showInvalidQRCodeAlert() {
        let alert = UIAlertController(title: qrScannerConfiguration.invalidQRCodeAlertTitle, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: qrScannerConfiguration.invalidQRCodeAlertActionTitle, style: .cancel))
        self.present(alert, animated: true)
    }
}


///Currently Scanner suppoerts only portrait mode.
///This makes sure orientation is portrait
extension QRCodeScannerController {
    //Make orientations to portrait
    
    override public var shouldAutorotate: Bool {
        return false
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }
}

extension QRCodeScannerController {
    
    private func addMaskToVideoPreviewLayer() {
        let qrFrameWidth: CGFloat = self.view.frame.size.width / 1.5
        let scanFrameWidth: CGFloat  = self.view.frame.size.width / 1.8
        let scanFrameHeight: CGFloat = self.view.frame.size.width / 1.8
        let screenHeight: CGFloat = self.view.frame.size.height / 2
        let roundViewFrame = CGRect(origin: CGPoint(x: self.view.frame.midX - scanFrameWidth/2,
                                                    y: self.view.frame.midY - screenHeight/2 + (qrFrameWidth-scanFrameWidth)/2),
                                    size: CGSize(width: scanFrameWidth, height: scanFrameHeight))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds
        maskLayer.fillColor = UIColor(white: 0.0, alpha: 0.5).cgColor
        let path = UIBezierPath(roundedRect: roundViewFrame, byRoundingCorners: [.allCorners], cornerRadii: CGSize(width: 10, height: 10))
        path.append(UIBezierPath(rect: view.bounds))
        maskLayer.path = path.cgPath
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        view.layer.insertSublayer(maskLayer, above: videoPreviewLayer)
        addHintTextLayer(maskLayer: maskLayer)
    }
    
    private func addHintTextLayer(maskLayer: CAShapeLayer) {
        guard let hint = qrScannerConfiguration.hint else { return }
        let hintTextLayer = CATextLayer()
        hintTextLayer.fontSize = 18.0
        hintTextLayer.string = hint
        hintTextLayer.alignmentMode = CATextLayerAlignmentMode.center
        hintTextLayer.contentsScale = UIScreen.main.scale
        hintTextLayer.frame = CGRect(x: spaceFactor,
                                     y: self.view.frame.midY - self.view.frame.size.height/4 - 62,
                                     width: view.frame.size.width - (2.0 * spaceFactor),
                                     height: 22)
        hintTextLayer.foregroundColor = UIColor.white.withAlphaComponent(0.7).cgColor
        view.layer.insertSublayer(hintTextLayer, above: maskLayer)
    }
}



public protocol QRScannerCodeDelegate: AnyObject {
    
    func qrScanner(_ controller: UIViewController, scanDidComplete result: String)
    func qrScannerDidFail(_ controller: UIViewController,  error: QRCodeError)
    func qrScannerDidCancel(_ controller: UIViewController)
}


extension UIImage {
    func parseQR() -> String? {
        guard let image = CIImage(image: self) else {
            return nil
        }
        let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                  context: nil,
                                  options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let features = detector?.features(in: image) ?? []
        return features.compactMap { feature in
            return (feature as? CIQRCodeFeature)?.messageString
        }.joined()
    }
}
