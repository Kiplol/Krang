//
//  ViewController.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/8/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit
import OAuthSwift

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func loginTapped(_ sender: AnyObject) {
        let oauth = OAuth2Swift(consumerKey: Constants.traktClientID, consumerSecret: Constants.traktClientSecret, authorizeUrl: Constants.traktAuthorizeURL, accessTokenUrl: Constants.traktAccessTokenURL, responseType: "code")
        oauth.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: oauth)
        let _ = oauth.authorize(withCallbackURL: Constants.traktRedirectURL, scope: "public", state: "ABCDE12345ABCDE12345ABCDE12345", success: { (credential, response, parameters) in
            //Yay
            print(credential)
            }) { (error) in
                //Boo
                print(error)
        }
    }
}

