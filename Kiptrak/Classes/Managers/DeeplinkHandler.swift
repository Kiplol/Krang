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
        if url.host == "externalurl" {
            self.handleExternalURL(url: url)
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

}
