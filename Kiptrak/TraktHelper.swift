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
            KrangLogger.log.debug("Successfully logged in")
            success?()
        }) { (error) in
            //Boo
            KrangLogger.log.error("Error loggin in: \(error)")
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
            
            KrangLogger.log.debug("Got profile for user \(user!.username)")
            
            completion?(nil, user)
            }) { (error) in
                //Boo
                KrangLogger.log.error("Error getting profile: \(error)")
                completion?(error, nil)
        }
    }
    
    func getCheckedInMovieOrEpisode(completion: ((_:Error?, _:KrangMovie?, _:KrangEpisode?) -> ())?) {
        let url = String.init(format: Constants.traktWatchingURLFormat, KrangUser.getCurrentUser().slug)
        let _ = self.oauth.client.get(url, parameters: [:], headers: TraktHelper.defaultHeaders(), success: { (response) in
            //Yay
            let json = JSON(data: response.data)
            let maybeMovieOrEpisode = TraktHelper.movieOrEpisodeFrom(json: json)
            if let actualMovie = maybeMovieOrEpisode as? KrangMovie {
                TMDBHelper.shared.update(movie: actualMovie, completion: { (error, updatedMovie) in
                    completion?(error, updatedMovie, nil)
                })
            } else if let actualEpisode = maybeMovieOrEpisode as? KrangEpisode {
                TMDBHelper.shared.update(episode: actualEpisode, completion: { (error, updatedEpisode) in
                    completion?(error, nil, updatedEpisode)
                })
            } else {
                completion?(nil, nil, nil)
            }
        }) { (error) in
            //Boo
            KrangLogger.log.error("Error getting currently watching movie or episode: \(error)")
            completion?(error, nil, nil)
        }
    }
    
    //Helpers
    private static func defaultHeaders() -> [String: String] {
        return ["Content-type": "application/json", "trakt-api-key": Constants.traktClientID, "trakt-api-version": "2"]
    }
    
    private static func movieOrEpisodeFrom(json:JSON) -> AnyObject? {
        guard json.type != SwiftyJSON.Type.null else {
            return nil
        }
        
        var resultMovie:KrangMovie? = nil
        var resultEpisode:KrangEpisode? = nil
        KrangRealmUtils.makeChanges {
            if let movie = KrangMovie.from(json: json) {
                //If it's new, save it to our database.
                if KrangMovie.with(traktID: movie.traktID) == nil {
                    movie.saveToDatabaseOutsideWriteTransaction()
                }
                resultMovie = movie
            } else if let episode = KrangEpisode.from(json: json) {
                //If it's new, save it to our database.
                if KrangEpisode.with(traktID: episode.traktID) == nil {
                    episode.saveToDatabaseOutsideWriteTransaction()
                }
                
                if let showID = json["show"]["ids"]["trakt"].int {
                    let show:KrangShow = {
                        if let existingShow = KrangShow.with(traktID: showID) {
                            existingShow.update(withJSON: json["show"])
                            return existingShow
                        } else {
                            let newShow = KrangShow()
                            newShow.update(withJSON: json["show"])
                            newShow.saveToDatabaseOutsideWriteTransaction()
                            return newShow
                        }
                    }()
                    
                    
                    if !episode.shows.contains(show) {
                        show.episodes.append(episode)
                    }
                }
                
                resultEpisode = episode
            }
        }
        
        if let movie = resultMovie {
            return movie
        } else if let episode = resultEpisode {
            return episode
        }
        return nil
    }

}
