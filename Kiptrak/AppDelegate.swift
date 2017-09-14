//
//  AppDelegate.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/8/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit
import OAuthSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    static var shared: AppDelegate {
        get {
            return UIApplication.shared.delegate as! AppDelegate
        }
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        BuddyBuildSDK.setup()
        
        self.setupAppearance()
        
        //Init the RealmManager
        let _ = RealmManager.shared
        
        //Init the logger
        KrangLogger.setup()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //MARK:- Deeplinks
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.host == "oauth-callback" {
            KrangLogger.log.debug("Got OAuth callback from URL: \(url)")
            OAuthSwift.handle(url: url)
        }
        DeeplinkHandler.shared.handle(url: url)
        return true
    }

    func setupAppearance() {
        UIWindow.appearance().tintColor = UIColor.white
//        UIView.appearance().tintColor = UIColor.white
        
        //Navigation Bar
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        UINavigationBar.appearance().barTintColor = UIColor.darkBackground
        UINavigationBar.appearance().isTranslucent = false
        
        //Buttons
        UIButton.appearance().tintColor = UIColor.white
        
        //Labels
        let labelAppearance = UILabel.appearance()
        labelAppearance.textColor = UIColor.white
        labelAppearance.fontName = "Exo-Light-Italic" //This seems to make it so that I can't ever set the font to something else...
        
        //Search Bars
        let searchBarTextFieldAppearance = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        searchBarTextFieldAppearance.textColor = UILabel.appearance().textColor
        searchBarTextFieldAppearance.tintColor = UIColor.white
        searchBarTextFieldAppearance.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        searchBarTextFieldAppearance.font = UIFont(name: "Exo-Light-Italic", size: 16.0)
    }
    
    func topViewController() -> UIViewController {
        return self.window!.rootViewController!.topViewController()
    }
    
}

