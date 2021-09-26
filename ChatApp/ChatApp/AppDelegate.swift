//
//  AppDelegate.swift
//  ChatApp
//
//  Created by Sophia Zhu on 8/30/21.
//

import UIKit
import Firebase
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var firstRun: Bool?
    


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        firstRunCheck() // check if it's the first time run or not
        LocationManager.shared.startUpdating()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Firstrun
    private func firstRunCheck() {
        print("first run check")
        firstRun = userDefaults.bool(forKey: kFIRSTRUN) // check , if nothing there, return false
        if !firstRun! {
            // first time run the app
            print("check first run!!!!")
            let status = Status.array.map { $0.rawValue }
            userDefaults.set(status,forKey: kSTATUS)
            userDefaults.set(true, forKey: kFIRSTRUN)
        }
        
    }


}

