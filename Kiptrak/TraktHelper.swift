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
import RealmSwift

class TraktHelper: NSObject {
    
    static let shared = TraktHelper()
    static let asyncImageLoadingOnSearch = false
    
    let oauth = OAuth2Swift(consumerKey: Constants.traktClientID, consumerSecret: Constants.traktClientSecret, authorizeUrl: Constants.traktAuthorizeURL, accessTokenUrl: Constants.traktAccessTokenURL, responseType: "code")
    private var didGetCredentials = false
    
    override init () {
        super.init()
        self.attemptToLoadCachedCredentials()
    }
    
    //MARK:- Credentials
    fileprivate func attemptToLoadCachedCredentials() {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.kip.krang") else {
            KrangLogger.log.error("Could not get UserDefaults for app group!  This is very bad!")
            return
        }
        if let cachedCredentialData = sharedDefaults.object(forKey: "traktCredentials") as? Data, let cachedCredential = NSKeyedUnarchiver.unarchiveObject(with: cachedCredentialData) as? OAuthSwiftCredential, cachedCredential.oauthToken.characters.count > 0 {
                cachedCredential.version = .oauth2
                self.oauth.client = OAuthSwiftClient(credential: cachedCredential)
                self.cache(credentials: self.oauth.client.credential)
                self.didGetCredentials = true
                KrangLogger.log.debug("Got cached Trakt credential object")
        } else if let cachedOAuthToken = sharedDefaults.string(forKey: "oauthToken") {
            
            let cachedOAuthTokenSecret = sharedDefaults.string(forKey: "oauthTokenSecret") ?? ""
            
            self.oauth.client.credential.oauthToken = cachedOAuthToken
            self.oauth.client.credential.oauthTokenSecret = cachedOAuthTokenSecret
            self.oauth.client.credential.oauthTokenExpiresAt = sharedDefaults.object(forKey: "oathTokenExpiresAt") as? Date
            self.oauth.client.credential.oauthRefreshToken = sharedDefaults.string(forKey: "oauthRefreshToken") ?? ""
            self.oauth.client.credential.version = .oauth2
            self.cache(credentials: self.oauth.client.credential)
            self.didGetCredentials = true
            KrangLogger.log.debug("Got cached Trakt credentials")
        } else {
            //Error unarchiving
            KrangLogger.log.error("Could not get cached Trakt credentials")
        }
    }
    
    fileprivate func cache(credentials credential:OAuthSwiftCredential) {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.kip.krang") else {
            KrangLogger.log.error("Could not get UserDefaults for app group!  This is very bad!")
            return
        }
        //First cache the actual object for the app...
        let data = NSKeyedArchiver.archivedData(withRootObject: credential)
        sharedDefaults.set(data, forKey: "traktCredentials")
        
        //Then cache the strings for the app extensions since they can't seem to fucking unarchive this object
        sharedDefaults.setValue(credential.oauthToken, forKey: "oauthToken")
        sharedDefaults.setValue(credential.oauthTokenSecret, forKey: "oauthTokenSecret")
        sharedDefaults.set(credential.oauthTokenExpiresAt, forKey: "oathTokenExpiresAt")
        sharedDefaults.set(credential.oauthRefreshToken, forKey: "oauthRefreshToken")
        sharedDefaults.synchronize()
    }
    
    func logout() {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.kip.krang") else {
            KrangLogger.log.error("Could not get UserDefaults for app group!  This is very bad!")
            return
        }
        
        sharedDefaults.removeObject(forKey: "traktCredentials")
        sharedDefaults.removeObject(forKey: "oauthToken")
        sharedDefaults.removeObject(forKey: "oathTokenExpiresAt")
        sharedDefaults.removeObject(forKey: "oauthRefreshToken")
        sharedDefaults.synchronize()
        KrangUser.getCurrentUser().makeChanges {
            KrangUser.setCurrentUser(nil)
        }
        self.didGetCredentials = false
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
                if let _ = actualMovie.posterImageURL {
                    completion?(nil, actualMovie, nil)
                } else {
                    TMDBHelper.shared.update(movie: actualMovie, completion: { (error, updatedMovie) in
                        completion?(error, updatedMovie, nil)
                    })
                }
            } else if let actualEpisode = maybeMovieOrEpisode as? KrangEpisode {
                if let _ = actualEpisode.posterImageURL {
                    completion?(nil, nil, actualEpisode)
                } else {
                    TMDBHelper.shared.update(episode: actualEpisode, completion: { (error, updatedEpisode) in
                        completion?(error, nil, updatedEpisode)
                    })
                }
            } else {
                completion?(nil, nil, nil)
            }
        }) { (error) in
            //Boo
            KrangLogger.log.error("Error getting currently watching movie or episode: \(error)")
            completion?(error, nil, nil)
        }
    }
    
    func search(withQuery query: String, completion: ((Error?, [KrangSearchable]) -> ())?) -> OAuthSwiftRequestHandle? {
        guard !query.isEmpty else {
            completion?(nil, [])
            return nil
        }
        guard let escapedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            completion?(nil, [])
            return nil
        }
        let url = String(format: Constants.traktSearchURLFormat, escapedQuery)
        let request = self.oauth.client.get(url, parameters: [:], headers: TraktHelper.defaultHeaders(), success: { (response) in
            //Success
            let json = JSON(data: response.data)
            var result: [KrangSearchable] = []
            if let matchDics = json.array {
                KrangRealmUtils.makeChanges {
                    matchDics.forEach {
                        guard let type = $0["type"].string else {
                            return
                        }
                        
                        switch type {
                        case "movie":
                            guard let traktID = $0["movie"]["ids"]["trakt"].int else {
                                return
                            }
                            
                            let thisJSON = $0
                            let movie:KrangMovie = {
                                if let existingMovie = KrangMovie.with(traktID: traktID) {
                                    existingMovie.update(withJSON: thisJSON)
                                    return existingMovie
                                } else {
                                    let newMovie = KrangMovie()
                                    newMovie.update(withJSON: thisJSON)
                                    newMovie.saveToDatabaseOutsideWriteTransaction()
                                    return newMovie
                                }
                            }()
                            result.append(movie)
                        default:
                            break
                        }
                    }
                }
            }
            let imageUpdateGroup = DispatchGroup()
            
            result.filter { $0.urlForSearchResultThumbnailImage == nil }.forEach {
                if let movie = $0 as? KrangMovie {
                    if !TraktHelper.asyncImageLoadingOnSearch {
                        imageUpdateGroup.enter()
                    }
                    TMDBHelper.shared.update(movie: movie, completion: { (_, updatedMovie) in
                        if !TraktHelper.asyncImageLoadingOnSearch {
                            imageUpdateGroup.leave()
                        }
                    })
                }
            }
            imageUpdateGroup.notify(queue: DispatchQueue.main) {
                completion?(nil, result)
            }
        }) { (error) in
            //Failure
            completion?(error, [])
        }
        
        return request
    }
    
    func checkIn(to watchable: KrangWatchable, completion: ((Error?, KrangWatchable?) -> ())?) {
        let url = Constants.trackCheckInURL
        guard var body = JSON(parseJSON: watchable.originalJSONString).dictionaryObject else {
            //@TODO: Error
            completion?(nil, nil)
            return
        }
        body["app_version"] = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let _ = self.oauth.client.post(url, parameters: body, headers: TraktHelper.defaultHeaders(), body: nil, success: { (response) in
            //Success
            completion?(nil, watchable)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name.didCheckInToWatchable, object: nil, userInfo: nil)
            }
        }) { (error) in
            //Failure
            print(error)
            completion?(error, nil)
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
