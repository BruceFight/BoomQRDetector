//
//  AppDelegate.swift
//  BoomQRDetector
//
//  Created by jianghongbao on 2021/4/13.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


/**
 RGBA颜色
 
 - parameter colorValue: 颜色值，16进制表示，如：0xffffff
 - parameter alpha:      透明度值
 
 - returns: 相应颜色
 */
func RGBA(_ colorValue: UInt32, alpha: CGFloat) -> UIColor {
    
    return UIColor.init(red: CGFloat((colorValue>>16)&0xFF)/256.0, green: CGFloat((colorValue>>8)&0xFF)/256.0, blue: CGFloat((colorValue)&0xFF)/256.0 , alpha: alpha)
}

/**
 RGB颜色
 
 - parameter colorValue: 颜色值，16进制表示，如：0xffffff
 
 - returns: 相应颜色
 */
func RGB(_ colorValue: UInt32) -> UIColor {
    return RGBA(colorValue, alpha: 1.0)
}



/// 随机颜色
///
/// - returns: 返回随机的颜色

func randomColor() -> UIColor {
    let redValue = CGFloat(arc4random_uniform(256))
    let greenValue = CGFloat(arc4random_uniform(256))
    let blueValue = CGFloat(arc4random_uniform(256))
    
    return UIColor.init(red: redValue / 255, green: greenValue / 255, blue: blueValue / 255, alpha: 1.0)
}

