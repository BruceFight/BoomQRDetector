//
//  ViewController.swift
//  BoomQRDetector
//
//  Created by jianghongbao on 2021/4/13.
//

import UIKit
import CoreImage
import CoreGraphics

class ViewController: UIViewController {

    fileprivate var textView = UITextView()
    fileprivate var transferBtn = UIButton()
    fileprivate var qrImage = UIImage()
    fileprivate var qrImageView = UIImageView()
    fileprivate var moreBtn = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.frame = CGRect.init(x: (view.bounds.width - 200) / 2, y: 100, width: 200, height: 150)
        textView.tintColor = .blue
        textView.backgroundColor = .lightGray
        textView.text = "❤️"
        view.addSubview(textView)
        
        transferBtn.frame = CGRect.init(x: 0, y: textView.frame.maxY + 15, width: 150, height: 30)
        transferBtn.center.x = view.center.x
        transferBtn.setTitle("Transfer to QR", for: .normal)
        transferBtn.setTitleColor(.black, for: .normal)
        transferBtn.addTarget(self, action: #selector(transfer), for: .touchUpInside)
        view.addSubview(transferBtn)
        
        qrImageView.frame = CGRect.init(x: 0, y: transferBtn.frame.maxY + 15, width: 100, height: 100)
        qrImageView.center.x = view.center.x
        view.addSubview(qrImageView)
        
        moreBtn.frame = CGRect.init(x: 0, y: textView.frame.minY - 50, width: 100, height: 30)
        moreBtn.setTitle("More", for: .normal)
        moreBtn.setTitleColor(.black, for: .normal)
        moreBtn.addTarget(self, action: #selector(more), for: .touchUpInside)
        view.addSubview(moreBtn)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//MARK: - Methods

extension ViewController {
    
    @objc func transfer() -> () {
        self.textView.resignFirstResponder()
        let dataString = textView.text
        if let filter: CIFilter = CIFilter.init(name: "CIQRCodeGenerator") {
            filter.setDefaults()
            let data = dataString?.data(using: String.Encoding.utf8)
            filter.setValue(data, forKey: "inputMessage")
            if let outputImage = filter.outputImage {
                qrImage = outputImage.improveImage()
                qrImageView.image = qrImage
            }
        }
    }
    
    @objc func more() -> () {
        let processorVc = BoomQRProcessorController()
        processorVc.qrImage = self.qrImage
        processorVc.modalPresentationStyle = .fullScreen
        self.present(processorVc, animated: true, completion: nil)
    }
    
}

extension CIImage {
    
    func improveImage() -> UIImage {
        var improve = UIImage()
        let extent: CGRect = self.extent.integral
        let size: CGSize = CGSize.init(width: 100, height: 100)
        let scale: CGFloat = min(size.width / extent.width, size.height / extent.height)
        let width: size_t = size_t(extent.width * scale)
        let height: size_t = size_t(extent.height * scale)
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapRef = CGContext.init(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.none.rawValue)
        let i_context = CIContext.init(options: nil)
        if let bitmapImage = i_context.createCGImage(self, from: extent) {
            bitmapRef?.interpolationQuality = CGInterpolationQuality.none
            bitmapRef?.scaleBy(x: scale, y: scale)
            bitmapRef?.draw(bitmapImage, in: extent)
            if let scaleImage = bitmapRef?.makeImage() {
                improve = UIImage.init(cgImage: scaleImage)
            }
        }
        return improve
    }
    
}


