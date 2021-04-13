//
//  BoomQRDetector.swift
//  BoomQRDetector
//
//  Created by jianghongbao on 2021/4/13.
//

import UIKit
import AVFoundation

enum HBQRErrorType: String {
    case none = "None error"
    case noDevice = "Failed to get the CaptureDevice"
    case noInput = "Failed to get the DeviceInput"
    case noQRCode = "No QR code is detected"
}

class BoomQRDetector: NSObject ,AVCaptureMetadataOutputObjectsDelegate {
    
    //public static let instance = BoomQRDetector()
    fileprivate var captureDevice: AVCaptureDevice?
    fileprivate var captureSession = AVCaptureSession()
    fileprivate var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    fileprivate var captureMetadataInput: AVCaptureDeviceInput?
    fileprivate var captureMetadataOutput = AVCaptureMetadataOutput()
    fileprivate var barcodeObject: AVMetadataObject?
    fileprivate var errorType: HBQRErrorType = .none
    
    public var previewLayerHandler: ((_ previewLayer: AVCaptureVideoPreviewLayer) -> ())?
    public var objectsHandler: ((_ metadataObjects: [AVMetadataObject]) -> ())?
    
    override init() {
        super.init()
    }
    
    public func setInterface() -> () {
        /// 1,Implement 'previewLayerHandler' attribute in main face
        
        /// 2,Configure attributes relatived to device
        getCaptureDevice()
    }
    
    fileprivate func getCaptureDevice() -> () {
        if #available(iOS 10.2, *) {
            let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
            captureDevice = deviceDiscoverySession.devices.first
            if let _ = captureDevice {
                
            }else {
                captureDevice = AVCaptureDevice.default(for: .video)
            }
        }else {
            captureDevice = AVCaptureDevice.default(for: .video)
        }
        guard let device = captureDevice else {
            errorType = .noDevice
            return
        }
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: device)
            captureMetadataInput = input
            // Set the input device on the capture session.
            if let _captureMetadataInput = captureMetadataInput {
                captureSession.addInput(_captureMetadataInput)
            }
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            if let _layer = videoPreviewLayer {
                previewLayerHandler?(_layer)
            }
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            errorType = .noInput
            return
        }
        
        // ❤️ 2,
        // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
        captureSession.addOutput(captureMetadataOutput)
        // Set delegate and use the default dispatch queue to execute the call back
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr,
                                                     .aztec,
                                                     .code128,
                                                     .code39,
                                                     .code93,
                                                     .code39Mod43,
                                                     .dataMatrix,
                                                     .ean13,
                                                     .ean8,
                                                     .face,
                                                     .itf14,
                                                     .pdf417,
                                                     .upce,
                                                     .interleaved2of5]
        startRunning()
    }
    
}

/// Operatations
extension BoomQRDetector {
    
    /// 开始运行
    func startRunning() -> () {
        captureSession.startRunning()
    }

    /// 结束运行
    func stopRunning() -> () {
        captureSession.stopRunning()
    }
    
    /// 灯光开与关
    func lightOnOrOff(lightHandler:((_ isLight:Bool) -> ())?) -> () {
        if isGetFlash() {
            var torch = false
            do {
                try captureMetadataInput?.device.lockForConfiguration()
                if captureMetadataInput?.device.torchMode == AVCaptureDevice.TorchMode.on {
                    torch = false
                }else if captureMetadataInput?.device.torchMode == AVCaptureDevice.TorchMode.off {
                    torch = true
                }
                captureMetadataInput?.device.torchMode = torch ? AVCaptureDevice.TorchMode.on: AVCaptureDevice.TorchMode.off
                captureMetadataInput?.device.unlockForConfiguration()
            }catch let error as NSError {
                print("device.lockForConfiguration(): \(error)")
            }
            lightHandler?(torch)
        }
    }
    
    fileprivate func isGetFlash() -> Bool {
        if let _captureDevice = captureDevice {
            if (_captureDevice.hasFlash && _captureDevice.hasTorch) {
                return true
            }
        }
        return false
    }
    
}

//MARK: - AVCaptureMetadataOutputObjectsDelegate

extension BoomQRDetector {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        errorType = .none
        if metadataObjects.count == 0 {
            errorType = .noQRCode
            return
        }
        objectsHandler?(metadataObjects)
    }
    
}
