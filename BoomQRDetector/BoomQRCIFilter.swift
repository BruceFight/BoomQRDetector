//
//  BoomQRCIFilter.swift
//  BoomQRDetector
//
//  Created by jianghongbao on 2021/4/13.
//

import UIKit

class BoomQRCIFilter: NSObject {
    
    /// 滤镜名称(e.g. @"CIMotionBlur"), 输出处理后的图片 -> "动态模糊"
    class func dynamicFuzzy(image:UIImage) -> UIImage {
        var resultImage: UIImage?
        
        if let ciImage = CIImage.init(image: image) {
            if let filter = CIFilter.init(name: "CIMotionBlur", parameters: [kCIInputImageKey:ciImage]) {
                filter.setValue(10, forKey: "inputRadius")
                if let outputImage = filter.outputImage {
                    let context = CIContext.init(options: nil)
                    if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                        resultImage = UIImage.init(cgImage: cgImage)
                    }
                }
            }
        }
        if let result = resultImage {
            return result
        }else {
            return UIImage()
        }
    }
    
}
