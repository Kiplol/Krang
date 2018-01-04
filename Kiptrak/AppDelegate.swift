//
//  AppDelegate.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/8/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit
import OAuthSwift
import LGAlertView

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    static var instance: AppDelegate!
    
    static var shared: AppDelegate {
        get {
            return UIApplication.shared.delegate as! AppDelegate
        }
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        BuddyBuildSDK.setup()
        AppDelegate.instance = self;
        self.setupAppearance()
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.didCheckInToAWatchable(_:)), name: Notification.Name.didCheckInToWatchable, object: nil)
        
        //Init the RealmManager
        let _ = RealmManager.shared
        
        if KrangUtils.isFirstTimeRunningThisVersion && !UserPrefs.traktSync {
            //Delete all the movies, seasons, etc
            RealmManager.makeChanges {
                RealmManager.deleteAllMoviesShowsSeasonsEpisodes()
            }
        }
        KrangUtils.setThisAsLastRunVersion()
        
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
        TraktHelper.shared.getCheckedInMovieOrEpisode { (error, movie, episode) in
            NotificationCenter.default.post(name: Notification.Name.didCheckInToWatchable, object: (movie ?? episode), userInfo: nil)
        }
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
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        UINavigationBar.appearance().barTintColor = UIColor.darkBackground
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        if #available(iOS 11.0, *) {
            UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        }
        
        //Buttons
        UIButton.appearance().tintColor = UIColor.white
        UIBarButtonItem.appearance().tintColor = UIColor.white
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], for: .normal)
        
        //Labels
        let labelAppearance = UILabel.appearance()
        labelAppearance.textColor = UIColor.white
        UILabel.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = UIColor(white: 1.0, alpha: 0.5)
        
        //Search Bars
        let searchBarTextFieldAppearance = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        searchBarTextFieldAppearance.textColor = UILabel.appearance().textColor
        searchBarTextFieldAppearance.tintColor = UIColor.white
        searchBarTextFieldAppearance.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        searchBarTextFieldAppearance.defaultTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.white] // <- Text color when it's in iOS 11's navigationItem thingy.
        
        //LGAlertView
//        LGAlertView.appearance().buttonsHeight = 44.0         //@TODO: This is just until that LGAlertView.m 2882 [self.tableView layoutIfNeeded] is released
        LGAlertView.appearance().buttonsTitleColor = UIColor.darkBackground
        LGAlertView.appearance().cancelButtonTitleColor = UIColor.gray
        LGAlertView.appearance().backgroundColor = UIColor.clear
        LGAlertView.appearance().backgroundBlurEffect = UIBlurEffect(style: .extraLight)
        LGAlertView.appearance().cancelButtonOffsetY = KrangUtils.safeAreaInsets.bottom
    }
    
    // MARK: - View Controller Heirarchy
    func topViewController() -> UIViewController {
        return self.window!.rootViewController!.topViewController()
    }
    
    // MARK: - Notifications
    @objc func didCheckInToAWatchable(_ notif: Notification) {
        if let watchable = notif.object as? KrangWatchable, let coverImageURL = watchable.fanartImageURL?.absoluteString {
            RealmManager.makeChanges {
                KrangUser.getCurrentUser().coverImageURL = coverImageURL
            }
        }
    }
    
}

