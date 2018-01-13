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
    open class var traktWatchingURLFormat: String { get { return Constants.traktBaseURL + "/users/%@/watching?extended=full" } }
    class var traktSearchURLFormat: String { return Constants.traktBaseURL + "/search/movie,show?query=%@&extended=full" }
    class var traktCheckInURL: String { return Constants.traktBaseURL + "/checkin" }
    class var traktGetShowSeasonsURLFormat: String { return Constants.traktBaseURL + "/shows/%@/seasons?extended=full" }
    class var traktGetShowSeasonsAndEpisodesURLFormat: String { return Constants.traktBaseURL + "/shows/%@/seasons?extended=full,episodes" }
    class var traktGetEpisodesForSeasonURLFormat: String { return Constants.traktBaseURL + "/shows/%@/seasons/%d?extended=full" }
    class var traktGetShowHistory: String { return Constants.traktBaseURL + "/sync/history/shows" }
    class var traktGetHistory: String { return Constants.traktBaseURL + "/sync/history" }
    class var traktGetActivity: String { return Constants.traktBaseURL + "/sync/last_activities" }
    class var traktGetShowHistoryFormat: String { return Constants.traktBaseURL + "/sync/history/shows/%d" }
    class var traktGetMovieExtendedInfoFormat: String { return Constants.traktBaseURL + "/movies/%d?extended=full" }
    class var traktMarkWatchedURL: String { return Constants.traktBaseURL + "/sync/history" }
    class var traktMarkUnwatchedURL: String { return Constants.traktBaseURL + "/sync/history/remove" }
    
    //MARK:- TMDB
    class var tmdbAPIKey: String { get { return "42261ec0aa6d07687f189a56f7b2363d" } }
    class var tmdbAPIReadAccessToken: String { get { return "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI0MjI2MWVjMGFhNmQwNzY4N2YxODlhNTZmN2IyMzYzZCIsInN1YiI6IjU4NzY3MTg2OTI1MTQxMDg3MjAwMDBiNSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.p_kIHeKSPM99z5aTJX_lHWaQenBLBH8_iJQB4oRpL8I" } }
    class var tmdbMovieGetURLFormat: String { get { return "https://api.themoviedb.org/3/movie/%d?api_key=\(Constants.tmdbAPIKey)&language=en-US" } }
    class var tmdbConfigurationURL: String { get { return "https://api.themoviedb.org/3/configuration?api_key=\(Constants.tmdbAPIKey)" } }
    class var tmdbEpisodeGetURLFormat: String { get { return "https://api.themoviedb.org/3/tv/%d%@/season/%d/episode/%d?api_key=\(Constants.tmdbAPIKey)&language=en-US" } }
    class var tmdbSeasonGetURLFormat: String { get { return "https://api.themoviedb.org/3/tv/%d%@/season/%d?api_key=\(Constants.tmdbAPIKey)&language=en-US" } }
    class var tmdbShowGetURLFormat: String { return "https://api.themoviedb.org/3/tv/%d%@?api_key=\(Constants.tmdbAPIKey)&language=en-US" }
    
    //MARK: IMDB
    open class var imdbURLFormat: String { get { return "http://www.imdb.com/title/%@/?ref_=Krang" } }
    
}

extension UIColor {
    class var darkBackground: UIColor { return UIColor(hex: "1E1E1E") }
    class var accent: UIColor { return UIColor(white: 1.0, alpha: 0.1) }
    class var progressFill: UIColor { return UIColor(hex: "4E4E4E") }
    class var tmdbBrandPrimaryLight: UIColor { return UIColor(hex: "01d277") }
    class var tmdbBrandPrimaryDark: UIColor { return UIColor(hex: "081c24") }
    class var imdbBrandPrimary: UIColor { return UIColor(hex: "f5de50") }
    class var traktBrandPrimary: UIColor { return UIColor(hex: "EA1921") }
}

extension Notification.Name {
//    public static var willEnterForeground: Notification.Name { get { return Notification.Name("willEnterForeground") } }
//    public static var didEnterBackground: Notification.Name { get { return Notification.Name("didEnterBackground") } }
    static var didCheckInToWatchable: Notification.Name { return Notification.Name("didCheckInToWatchable") }
}
