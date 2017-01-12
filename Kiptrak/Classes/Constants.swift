//
//  Constants.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/8/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit
import Hue

class Constants: NSObject {
    
    //MARK:- Trakt
    open class var traktClientID: String { get { return "8fe969601ed2f6a00f34bf9c6691bb1edd35f52358a61373ba1fd74a6c4c5342" } }
    open class var traktClientSecret: String { get { return "10005cf1cf0c7bfbd27d87c2bafeee75c4504786378d6925887fc7d450a90813" } }
    open class var traktRedirectURL: String { get { return "http://elliottkipper.com/apps/kiptrak/auth.php" } }
    open class var traktAuthorizeURL: String { get { return "https://api.trakt.tv/oauth/authorize" } }
    open class var traktAccessTokenURL: String { get { return "https://api.trakt.tv/oauth/token" } }
    open class var traktBaseURL: String { get { return "https://api.trakt.tv" } }
    open class var traktWatchingURLFormat: String { get { return Constants.traktBaseURL + "/users/%@/watching" } }
    
    //MARK:- TMDB
    open class var tmdbAPIKey: String { get { return "42261ec0aa6d07687f189a56f7b2363d" } }
    open class var tmdbAPIReadAccessToken: String { get { return "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI0MjI2MWVjMGFhNmQwNzY4N2YxODlhNTZmN2IyMzYzZCIsInN1YiI6IjU4NzY3MTg2OTI1MTQxMDg3MjAwMDBiNSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.p_kIHeKSPM99z5aTJX_lHWaQenBLBH8_iJQB4oRpL8I" } }
    open class var tmdbMovieGetURLFormat: String { get { return "https://api.themoviedb.org/3/movie/%d?api_key=\(Constants.tmdbAPIKey)&language=en-US" } }
    open class var tmdbConfigurationURL: String { get { return "https://api.themoviedb.org/3/configuration?api_key=\(Constants.tmdbAPIKey)" } }
    
    //MARK: IMDB
    open class var imdbURLFormat: String { get { return "http://www.imdb.com/title/%@/?ref_=Krang" } }
    
}

extension UIColor {
    class var darkBackground: UIColor { get { return UIColor(hex: "1E1E1E") } }
}
