//
//  TraktHelper.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/9/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit

import OAuthSwift
import SwiftyJSON

class TraktHelper: NSObject {
    
    static let shared = TraktHelper()
    
    let oauth = OAuth2Swift(consumerKey: Constants.traktClientID, consumerSecret: Constants.traktClientSecret, authorizeUrl: Constants.traktAuthorizeURL, accessTokenUrl: Constants.traktAccessTokenURL, responseType: "code")
    
    override init () {
        super.init()
        self.attemptToLoadCachedCredentials()
    }
    
    fileprivate func attemptToLoadCachedCredentials() {
        let sharedDefaults = UserDefaults(suiteName: "group.com.kip.krang")
        if let cachedCredentialData = sharedDefaults?.object(forKey: "traktCredentials") as? Data {
            if let cachedCredential = NSKeyedUnarchiver.unarchiveObject(with: cachedCredentialData) as? OAuthSwiftCredential {
                self.oauth.client = OAuthSwiftClient(credential: cachedCredential)
            } else {
                //Error unarchiving
            }
        }
    }
    
    fileprivate func cache(credentials credential:OAuthSwiftCredential) {
        let data = NSKeyedArchiver.archivedData(withRootObject: credential)
        let sharedDefaults = UserDefaults(suiteName: "group.com.kip.krang")
        sharedDefaults?.set(data, forKey: "traktCredentials")
    }
    
    
    func login(from presentingViewController: UIViewController, success: (() -> ())?, failure: ((_ error:Error?) -> ())?) {
        self.oauth.authorizeURLHandler = SafariURLHandler(viewController: presentingViewController, oauthSwift: oauth)
        let _ = oauth.authorize(withCallbackURL: Constants.traktRedirectURL, scope: "public", state: "ABCDE12345ABCDE12345ABCDE12345", success: { (credential, response, parameters) in
            //Yay
            print(credential)
            self.cache(credentials: credential)
            success?()
        }) { (error) in
            //Boo
            print(error)
            failure?(error)
        }
    }
    
    func getMyProfile(completion: (() -> ())? ) {
        let _ = self.oauth.client.get(Constants.traktBaseURL + "/users/settings", parameters: [:], headers: TraktHelper.defaultHeaders(), success: { (response) in
            //Yay
            let json = JSON(data: response.data)
            completion?()
            }) { (error) in
                //Boo
                print(error)
                completion?()
        }
    }
    
    //Helpers
    private static func defaultHeaders() -> [String: String] {
        return ["Content-type": "application/json", "trakt-api-key": Constants.traktClientID, "trakt-api-version": "2"]
    }

}
