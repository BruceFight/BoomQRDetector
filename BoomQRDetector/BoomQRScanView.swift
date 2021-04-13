//
//  BoomQRScanView.swift
//  BoomQRDetector
//
//  Created by jianghongbao on 2021/4/13.
//


import UIKit
import AVFoundation

class BoomQRScanView: UIView {
    
    fileprivate var detector = BoomQRDetector()
    fileprivate var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    fileprivate var backLayer = CAShapeLayer()
    fileprivate var centerLayer = CAShapeLayer()
    fileprivate var angles: [CGFloat] = [0,CGFloat.pi/2,CGFloat.pi,-CGFloat.pi/2]
    fileprivate var paramXYs: [[CGFloat]] = [[]]
    fileprivate var corners: [UIImageView] = []
    
    fileprivate var limitView = UIView()
    fileprivate var takeView = UIView()
    fileprivate var gridView = UIImageView()
    fileprivate var lineView = UIImageView()
    fileprivate var loadingView = UIImageView()
    
    fileprivate var implementLabel = UILabel()
    fileprivate var introduceLabel = UILabel()
    fileprivate var lightBtn = UIButton()
    
    var messageHandler: ((_ message:String ,_ position:CGRect ,_ detector:BoomQRDetector) -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        /// Configure
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground(notifi:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        backgroundColor = UIColor.clear
        
        /// Set detector
        setDertector()
        
        /// Interface
        setSubviews()
    }
    
    func setSubviews() -> () {
        centerLayer.backgroundColor = UIColor.clear.cgColor
        centerLayer.borderWidth = 1
        centerLayer.borderColor = RGB(0x00BE75).cgColor
        centerLayer.masksToBounds = true
        layer.addSublayer(centerLayer)
        
        takeView.backgroundColor = .clear
        gridView.image = #imageLiteral(resourceName: "login_scan_img1")
        gridView.contentMode = .scaleAspectFill
        takeView.addSubview(gridView)
        
        lineView.image = #imageLiteral(resourceName: "login_scan_img2")
        takeView.addSubview(lineView)
        
        limitView.clipsToBounds = true
        limitView.addSubview(takeView)
        addSubview(limitView)
        
        loadingView.image = #imageLiteral(resourceName: "loading")
        loadingView.isHidden = true
        addSubview(loadingView)
        
        implementLabel.text = "请扫描二维码"
        implementLabel.textAlignment = .center
        implementLabel.font = UIFont.init(name: "PingFangSC-Medium", size: 20)
        implementLabel.textColor = RGB(0xFFFFFF)
        implementLabel.sizeToFit()
        addSubview(implementLabel)
        
        introduceLabel.text = "将二维码放入框内，即可自动扫描"
        introduceLabel.textAlignment = .center
        introduceLabel.font = UIFont.init(name: "PingFangSC-Regular", size: 13)
        introduceLabel.textColor = RGB(0x00D078)
        introduceLabel.sizeToFit()
        addSubview(introduceLabel)
        
        lightBtn.setImage(#imageLiteral(resourceName: "login_scan_flashlightOn_nor"), for: .normal)
        lightBtn.addTarget(self, action: #selector(lightOnOrOff), for: .touchUpInside)
        addSubview(lightBtn)
        
        for i in 0 ..< angles.count {
            let cornerImageView = UIImageView.init(image: #imageLiteral(resourceName: "login_scan_img3"))
            let angle = angles[i]
            cornerImageView.transform = CGAffineTransform.init(rotationAngle: angle)
            cornerImageView.sizeToFit()
            corners.append(cornerImageView)
            addSubview(cornerImageView)
        }
        
        layer.addSublayer(backLayer)
    }
    
    func setDertector() -> () {
        detector.previewLayerHandler = {[weak self] (videoPreviewLayer) in
            if let strongSelf = self {
                videoPreviewLayer.frame = strongSelf.layer.bounds
                strongSelf.layer.addSublayer(videoPreviewLayer)
                strongSelf.videoPreviewLayer = videoPreviewLayer
            }
        }
        
        detector.objectsHandler = {[weak self] (metadataObjects) in
            if let strongSelf = self {
                strongSelf.setLoadingShow(show: true)
                if let firstObject = metadataObjects.first {
                    if let metadataObj = firstObject as? AVMetadataMachineReadableCodeObject {//可读码
                        // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
                        strongSelf.tracePosition(metadataObj: metadataObj, message: metadataObj.stringValue)
                    }else if let metadataObj = firstObject as? AVMetadataFaceObject {//人脸码
                        let faceID: String = "\(metadataObj.faceID)"
                        strongSelf.tracePosition(metadataObj: metadataObj, message: faceID)
                    }
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                        strongSelf.setLoadingShow(show: false)
                    })
                }
            }
        }
        
        detector.setInterface()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        centerLayer.frame = CGRect.init(x: (bounds.width - 260) / 2, y: (bounds.height - 260) / 2, width: 260, height: 260)
        implementLabel.frame = CGRect.init(x: 0, y: centerLayer.frame.minY - implementLabel.bounds.height - 70, width: implementLabel.bounds.width, height: implementLabel.bounds.height)
        implementLabel.center.x = center.x
        introduceLabel.frame = CGRect.init(x: 0, y: centerLayer.frame.maxY + 20, width: introduceLabel.bounds.width, height: introduceLabel.bounds.height)
        lightBtn.frame = CGRect.init(x: 0, y: bounds.height - 80, width: 48, height: 48)
        lightBtn.center.x = center.x
        introduceLabel.center.x = center.x
        paramXYs = [[centerLayer.frame.minX + 1, centerLayer.frame.minY + 1],
                    [centerLayer.frame.maxX - 29, centerLayer.frame.minY + 1],
                    [centerLayer.frame.maxX - 29, centerLayer.frame.maxY - 29],
                    [centerLayer.frame.minX + 1, centerLayer.frame.maxY - 29]]
        for i in 0 ..< corners.count {
            let corner = corners[i]
            corner.frame = CGRect.init(x: paramXYs[i][0], y: paramXYs[i][1], width: 28, height: 28)
        }
        limitView.frame = CGRect.init(x: (bounds.width - 354) / 2, y: centerLayer.frame.minY, width: 354, height: centerLayer.bounds.height)
        takeView.frame = CGRect.init(x: 0, y: -161, width: limitView.bounds.width, height: 161)
        gridView.frame = CGRect.init(x: (354 - centerLayer.bounds.width) / 2, y: -160, width: centerLayer.bounds.width, height: 160)
        lineView.frame = CGRect.init(x: 0, y: gridView.frame.maxY - 2, width: takeView.bounds.width, height: 3)
        videoPreviewLayer?.frame = bounds
        backLayer.frame = bounds
        loadingView.frame = CGRect.init(x: 0, y: 0, width: 100, height: 100)
        loadingView.center = limitView.center
        allAnimations()
    }
 
    var remainColor: UIColor = RGBA(0x000000, alpha: 0.4)
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        let big = UIBezierPath.init(rect: bounds)
        let bezier = UIBezierPath.init(rect: centerLayer.frame)
        big.append(bezier)
        big.usesEvenOddFillRule = true
        backLayer.path = big.cgPath
        backLayer.fillRule = .evenOdd
        backLayer.fillColor = remainColor.cgColor
        backLayer.opacity = 0.5
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("❤️ Deinit: \(self)")
    }
    
}

extension BoomQRScanView {
    
    /// 获取从后台进入前台的通知
    @objc func willEnterForeground(notifi:Notification) {
        allAnimations()
    }
    
    func allAnimations() -> () {
        setMoveAnimation(_view: takeView, from: -takeView.bounds.height / 2, to: CFloat(takeView.bounds.height + takeView.bounds.height))
        setRotateAnimation(_view: loadingView, values: [0,Float(2.0 * CGFloat.pi)])
    }
    
    /// 位移动画
    func setMoveAnimation(_view:UIView,from:CGFloat,to:CFloat) -> () {
        let anim = CABasicAnimation.init(keyPath: "position.y")
        anim.fromValue = from
        anim.toValue = to
        anim.duration = 3
        anim.repeatCount = .infinity
        anim.beginTime = CACurrentMediaTime()
        _view.layer.add(anim, forKey: "move-layer")
    }
    
    /// 旋转动画
    func setRotateAnimation(_view:UIView,values:[CFloat]) -> () {
        let anim = CAKeyframeAnimation.init(keyPath: "transform.rotation.z")
        anim.values = values
        anim.duration = 2
        anim.autoreverses = false
        anim.repeatCount = .infinity
        anim.beginTime = CACurrentMediaTime()
        _view.layer.add(anim, forKey: "shake-layer")
    }
    
    /// 显示隐藏加载中视图(动画)
    func setLoadingShow(show:Bool) -> () {
        UIView.animate(withDuration: 0.25) {
            self.loadingView.isHidden = !show
        }
    }
    
    /// 灯光开与关
    @objc func lightOnOrOff() -> () {
        detector.lightOnOrOff {[weak self] (isLight) in
            if let strongSelf = self {
                if isLight {
                    strongSelf.lightBtn.setImage(#imageLiteral(resourceName: "login_scan_flashlightOn_nor"), for: .normal)
                }else {
                    strongSelf.lightBtn.setImage(#imageLiteral(resourceName: "login_scan_flashlightOn_pre"), for: .normal)
                }
            }
        }
    }
    
    /// 追踪二维码位置与信息
    func tracePosition(metadataObj:AVMetadataObject,message:String?) -> () {
        if let barCodeObject = self.videoPreviewLayer?.transformedMetadataObject(for: metadataObj) ,let msg = message {
            messageHandler?(msg, barCodeObject.bounds, detector)
        }
    }
    
}
