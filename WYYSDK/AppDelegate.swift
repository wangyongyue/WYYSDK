//
//  AppDelegate.swift
//  WYYSDK
//
//  Created by wyy on 2023/5/29.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    public var window:UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: ViewController())
        window?.makeKeyAndVisible()
        return true
    }

   


}

