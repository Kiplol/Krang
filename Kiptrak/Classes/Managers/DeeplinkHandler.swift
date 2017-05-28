//
//  DeeplinkHandler.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/16/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit

class DeeplinkHandler: NSObject {
    
    static let shared = DeeplinkHandler()
    
    func handle(url:URL) {
        if let host = url.host {
            switch host {
            case "externalurl":
                self.handleExternalURL(url: url)
            case "traktlogin":
                self.handleTraktLogin(url: url)
            default:
                break
            }
        }
    }
    
    func handleExternalURL(url:URL) {
        guard url.host == "externalurl" else {
            return
        }
        
        let szURL = url.absoluteString
        let szExternalURL = szURL.replacingOccurrences(of: "krang://\(url.host!)/", with: "")
        if let finalURL = URL(string: szExternalURL) {
            UIApplication.shared.open(finalURL, options: [:], completionHandler: nil)
        }
    }
    
    func handleTraktLogin(url: URL) {
        guard url.host == "traktlogin" else {
            return
        }
        
        guard !TraktHelper.shared.credentialsAreValid() else {
            return
        }
        
        var splashVC: SplashViewController? = AppDelegate.shared.topViewController() as? SplashViewController
        
        if splashVC == nil {
            let splashNav = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController() as? UINavigationController
            splashVC = splashNav?.topViewController as? SplashViewController
            UIApplication.shared.keyWindow?.rootViewController = splashNav
        }
        
        splashVC?.loginAfterAppear()
    }
}
