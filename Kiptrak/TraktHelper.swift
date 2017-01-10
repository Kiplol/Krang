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
    private var didGetCredentials = false
    
    override init () {
        super.init()
        self.attemptToLoadCachedCredentials()
    }
    
    //MARK:- Credentials
    fileprivate func attemptToLoadCachedCredentials() {
        let sharedDefaults = UserDefaults(suiteName: "group.com.kip.krang")
        if let cachedCredentialData = sharedDefaults?.object(forKey: "traktCredentials") as? Data {
            if let cachedCredential = NSKeyedUnarchiver.unarchiveObject(with: cachedCredentialData) as? OAuthSwiftCredential {
                self.didGetCredentials = true
                cachedCredential.version = .oauth2
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
    
    func credentialsNeedRefresh() -> Bool {
        return self.didGetCredentials && self.oauth.client.credential.isTokenExpired()
    }
    
    func credentialsAreValid() -> Bool {
        if !self.didGetCredentials {
            return false
        }
        
        if self.oauth.client.credential.isTokenExpired() {
            return false
        }
        
        return true
    }
    
    //MARK:- Real Shit
    func login(from presentingViewController: UIViewController, success: (() -> ())?, failure: ((_ error:Error?) -> ())?) {
        self.oauth.authorizeURLHandler = SafariURLHandler(viewController: presentingViewController, oauthSwift: oauth)
        let _ = oauth.authorize(withCallbackURL: Constants.traktRedirectURL, scope: "public", state: "ABCDE12345ABCDE12345ABCDE12345", success: { (credential, response, parameters) in
            //Yay
            self.didGetCredentials = true
            self.cache(credentials: credential)
            success?()
        }) { (error) in
            //Boo
            print(error)
            failure?(error)
        }
    }
    
    func getMyProfile(completion: ((_:Error?,  _:KrangUser?) -> ())? ) {
        let _ = self.oauth.client.get(Constants.traktBaseURL + "/users/settings", parameters: [:], headers: TraktHelper.defaultHeaders(), success: { (response) in
            //Yay
            let json = JSON(data: response.data)
            var user:KrangUser? = nil
            
            KrangRealmUtils.makeChanges {
                user = KrangUser.from(json: json)
                KrangUser.setCurrentUser(user)
            }
            
            completion?(nil, user)
            }) { (error) in
                //Boo
                print(error)
                completion?(error, nil)
        }
    }
    
    //Helpers
    private static func defaultHeaders() -> [String: String] {
        return ["Content-type": "application/json", "trakt-api-key": Constants.traktClientID, "trakt-api-version": "2"]
    }

}
