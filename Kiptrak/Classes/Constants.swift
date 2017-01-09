//
//  Constants.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/8/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit

class Constants: NSObject {
    
    //MARK:- Trakt
    open class var traktClientID: String { get { return "8fe969601ed2f6a00f34bf9c6691bb1edd35f52358a61373ba1fd74a6c4c5342" } }
    open class var traktClientSecret: String { get { return "10005cf1cf0c7bfbd27d87c2bafeee75c4504786378d6925887fc7d450a90813" } }
    open class var traktRedirectURL: String { get { return "http://elliottkipper.com/apps/kiptrak/auth.php" } }
    open class var traktAuthorizeURL: String { get { return "https://api.trakt.tv/oauth/authorize" } }
    open class var traktAccessTokenURL: String { get { return "https://api.trakt.tv/oauth/token" } }
    open class var traktBaseURL: String { get { return "https://api.trakt.tv" } }
    
}
