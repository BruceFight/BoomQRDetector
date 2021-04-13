//
//  BoomQRProcessorController.swift
//  BoomQRDetector
//
//  Created by jianghongbao on 2021/4/13.
//

import UIKit
import AVFoundation
import Photos

class BoomQRProcessorController: UIViewController ,UINavigationControllerDelegate ,UIImagePickerControllerDelegate {
    
    fileprivate var dismissBtn = UIButton()
    fileprivate var scanView = BoomQRScanView()
    fileprivate var qrCodeFrameView = UIView()
    fileprivate var messageLabel = UILabel()
    
    var qrImage = UIImage()
    fileprivate var qrImageView = UIImageView()
    fileprivate var detectorBtn = UIButton()
    fileprivate var moreBtn = UIButton()
    
    weak var detector:BoomQRDetector?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scanView.messageHandler = {[weak self](message,position,detector) in
            if let strongSelf = self {
                strongSelf.detector = detector
                detector.stopRunning()
                strongSelf.qrCodeFrameView.frame = position
                strongSelf.messageLabel.text = message
                strongSelf.messageSizeToFit(content: message)
            }
        }
        scanView.frame = view.bounds
        view.addSubview(scanView)
        scanView.setNeedsDisplay()
        
        /// Set interface subviews
        qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
        qrCodeFrameView.layer.borderWidth = 2
        view.addSubview(qrCodeFrameView)
        view.bringSubviewToFront(qrCodeFrameView)
        
        messageLabel.textColor = .red
        messageLabel.font = .boldSystemFont(ofSize: 15)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        view.addSubview(messageLabel)
        view.bringSubviewToFront(messageLabel)
        
        dismissBtn.frame = CGRect.init(x: 10, y: 10, width: 100, height: 100)
        dismissBtn.setTitle("Dismiss", for: .normal)
        dismissBtn.setTitleColor(.red, for: .normal)
        dismissBtn.backgroundColor = .clear
        dismissBtn.addTarget(self, action: #selector(dis), for: .touchUpInside)
        view.addSubview(dismissBtn)
        
        qrImageView.frame = CGRect.init(x: view.bounds.width - 100, y: 0, width: 100, height: 100)
        qrImageView.image = qrImage
        view.addSubview(qrImageView)
        
        detectorBtn.frame = CGRect.init(x: 0, y: qrImageView.frame.maxY + 10, width: 100, height: 30)
        detectorBtn.center.x = qrImageView.center.x
        detectorBtn.setTitle("Detect", for: .normal)
        detectorBtn.setTitleColor(.blue, for: .normal)
        detectorBtn.backgroundColor = .black
        detectorBtn.addTarget(self, action: #selector(detect), for: .touchUpInside)
        view.addSubview(detectorBtn)
        
        moreBtn.frame = CGRect.init(x: 0, y: detectorBtn.frame.maxY + 10, width: 100, height: 30)
        moreBtn.center.x = qrImageView.center.x
        moreBtn.setTitle("More", for: .normal)
        moreBtn.setTitleColor(.blue, for: .normal)
        moreBtn.backgroundColor = .black
        moreBtn.addTarget(self, action: #selector(more), for: .touchUpInside)
        view.addSubview(moreBtn)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("❤️ Deinit: \(self)")
    }
}

//MARK: - Methods
extension BoomQRProcessorController {
    @objc func dis() -> () {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func detect() -> () {
        //let img = BoomQRCIFilter.dynamicFuzzy(image: qrImage)
        //qrImageView.image = img
        detector?.startRunning()
        scanQRImage(qrImage: qrImage)
    }
    
    @objc func more() -> () {
        let alterVc = UIAlertController.init(title: "More", message: "Choose image source from album or camera !", preferredStyle: .actionSheet)
        let albumAction = UIAlertAction.init(title: "Album", style: .default) { (action) in
            /// Open album
            self.openAlbum()
        }
        alterVc.addAction(albumAction)
        
        let cameraAction = UIAlertAction.init(title: "Camera", style: .default) { (action) in
            /// Open camera
            self.openCamera()
        }
        alterVc.addAction(cameraAction)
        self.present(alterVc, animated: true, completion: nil)
    }
    
    func messageSizeToFit(content:String?) -> () {
        messageLabel.text = content
        messageLabel.sizeToFit()
        messageLabel.frame = CGRect.init(x: 15, y: view.bounds.height - messageLabel.bounds.height - 80, width: view.bounds.width - 30, height: messageLabel.bounds.height)
    }
    
    func setResultImage(image:UIImage) -> () {
        qrImage = image
        qrImageView.image = image
    }

    /// 扫描疑似QR图片
    func scanQRImage(qrImage:UIImage) -> () {
        guard let imageData = qrImage.pngData() else {
            messageSizeToFit(content: "疑似QR图片转为Data数据失败 !!!")
            return
        }
        let ciImage = CIImage.init(data: imageData)
        let context = CIContext.init(options: [CIContextOption.useSoftwareRenderer:true])
        var kIfSuccess: Bool = false
        if let _ciImage = ciImage {
            let qrDetector = CIDetector.init(ofType: CIDetectorTypeQRCode, context: context, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])
            if let features = qrDetector?.features(in: _ciImage) {
                if features.count > 0 {
                    for feature in features {
                        if feature.isKind(of: CIQRCodeFeature.self) {
                            if let qrFeature = feature as? CIQRCodeFeature {
                                kIfSuccess = true
                                messageSizeToFit(content: qrFeature.messageString)
                            }
                        }
                    }
                }
            }
        }
        if !kIfSuccess {
            messageSizeToFit(content: "疑似QR图片没有读出数据 !!!")
        }
    }
}

//MARK: - UIImagePickerviewController
extension BoomQRProcessorController {
    func openAlbum() -> () {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let authorStatus = PHPhotoLibrary.authorizationStatus()
            switch authorStatus {
            case .denied ,.restricted:
                let alertVc = UIAlertController.init(title: "Prompt", message: "Have no permission", preferredStyle: .alert)
                self.present(alertVc, animated: true, completion: nil)
                break
            case .authorized:
                let pickerVc = UIImagePickerController.init()
                pickerVc.sourceType = .photoLibrary
                pickerVc.delegate = self
                pickerVc.allowsEditing = true
                pickerVc.modalTransitionStyle = .crossDissolve
                pickerVc.view.tag = self.hash
                self.present(pickerVc, animated: true, completion: nil)
                break
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({ (status) in
                    if status == .authorized {
                        let pickerVc = UIImagePickerController.init()
                        pickerVc.sourceType = .photoLibrary
                        pickerVc.delegate = self
                        pickerVc.allowsEditing = true
                        pickerVc.modalTransitionStyle = .crossDissolve
                        pickerVc.view.tag = self.hash
                        self.present(pickerVc, animated: true, completion: nil)
                    }else {
                        let alertVc = UIAlertController.init(title: "Prompt", message: "Unsupport PhotoLibrary", preferredStyle: .alert)
                        self.present(alertVc, animated: true, completion: nil)
                    }
                })
                break
            case .limited:
                break
            @unknown default:
                fatalError()
            }
        }else {
            let alertVc = UIAlertController.init(title: "Prompt", message: "Unsupport PhotoLibrary", preferredStyle: .alert)
            self.present(alertVc, animated: true, completion: nil)
        }
       
    }
    
    func openCamera() -> () {
        let authorStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authorStatus {
        case AVAuthorizationStatus.restricted,AVAuthorizationStatus.denied:
            let alertVc = UIAlertController.init(title: "Prompt", message: "Have no permission", preferredStyle: .alert)
            self.present(alertVc, animated: true, completion: nil)
            break
        case AVAuthorizationStatus.authorized:
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let pickerVc = UIImagePickerController.init()
                pickerVc.sourceType = .camera
                pickerVc.delegate = self
                pickerVc.allowsEditing = false
                pickerVc.view.tag = self.hash
                self.present(pickerVc, animated: true, completion: nil)
            }else {
                let alertVc = UIAlertController.init(title: "Prompt", message: "Unsupport Camera", preferredStyle: .alert)
                self.present(alertVc, animated: true, completion: nil)
            }
            break
        case AVAuthorizationStatus.notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                if granted {
                    let pickerVc = UIImagePickerController.init()
                    pickerVc.sourceType = .camera
                    pickerVc.delegate = self
                    pickerVc.allowsEditing = false
                    pickerVc.view.tag = self.hash
                    self.present(pickerVc, animated: true, completion: nil)
                }else {
                    let alertVc = UIAlertController.init(title: "Prompt", message: "Unsupport Camera", preferredStyle: .alert)
                    self.present(alertVc, animated: true, completion: nil)
                }
            })
            break
        @unknown default:
            fatalError()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        self.dismiss(animated: true, completion: nil)
        if picker.view.tag == self.hash { /// Camera
            if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
                //NSData *imgData = UIImageJPEGRepresentation(image, 0.6);
                if let scaleImageData = image.jpegData(compressionQuality: 0.5) {
                    if let result = UIImage.init(data: scaleImageData) {
                        self.scanQRImage(qrImage: result)
                        self.setResultImage(image: result)
                    }else {
                        self.scanQRImage(qrImage: image)
                        self.setResultImage(image: image)
                    }
                }
            }
        }else {/// Album
            if let image = info["UIImagePickerControllerEditedImage"] as? UIImage {
                self.scanQRImage(qrImage: image)
                self.setResultImage(image: image)
            }
        }
    }
}

