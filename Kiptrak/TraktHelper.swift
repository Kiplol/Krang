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
    static let asyncImageLoadingOnSearch = true
    
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
        if let cachedCredentialData = sharedDefaults.object(forKey: "traktCredentials") as? Data, let cachedCredential = NSKeyedUnarchiver.unarchiveObject(with: cachedCredentialData) as? OAuthSwiftCredential, !cachedCredential.oauthToken.isEmpty {
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
            KrangUser.getCurrentUser().lastHistorySync = Date.distantPast
            RealmManager.removeAllWatchDates()
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
            do {
                let json = try JSON(data: response.data)
                var user:KrangUser? = nil
                
                RealmManager.makeChanges {
                    user = KrangUser.from(json: json)
                    KrangUser.setCurrentUser(user)
                }
                
                KrangLogger.log.debug("Got profile for user \(user!.username)")
                
                completion?(nil, user)
            } catch let jsonError {
                completion?(jsonError, nil)
            }
        }) { (error) in
            //Boo
            KrangLogger.log.error("Error getting profile: \(error)")
            completion?(error, nil)
        }
    }
    
    func getLastActivityTime(_ completion: ((Error?, Date?) -> ())?) {
        //@TODO
        let _ = self.oauth.client.get(Constants.traktGetActivity, parameters: [:], headers: TraktHelper.defaultHeaders(), success: { (response) in
            //Yay
            do {
            let json = try JSON(data: response.data)
            if let szTime = json["all"].string, let time = Date.from(utcTimestamp: szTime) {
                completion?(nil, time)
            } else {
                completion?(nil, nil)
            }
            } catch let jsonError {
                completion?(jsonError, nil)
            }
        }) { (error) in
            //Boo
            completion?(error, nil)
        }
    }
    
    func getCheckedInMovieOrEpisode(completion: ((_:Error?, _:KrangMovie?, _:KrangEpisode?) -> ())?) {
        let url = String.init(format: Constants.traktWatchingURLFormat, KrangUser.getCurrentUser().slug)
        let _ = self.oauth.client.get(url, parameters: [:], headers: TraktHelper.defaultHeaders(), success: { (response) in
            //Yay
            do {
                let json = try JSON(data: response.data)
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
                    //                if let _ = actualEpisode.posterImageURL {
                    //                    completion?(nil, nil, actualEpisode)
                    //                } else {
                    TMDBHelper.shared.update(episode: actualEpisode, completion: { (error, updatedEpisode) in
                        if let show = updatedEpisode?.show {
                            TMDBHelper.shared.update(show: show, completion: { (showError, updatedShow) in
                                if updatedEpisode!.posterImageURL == nil {
                                    updatedEpisode!.makeChanges {
                                        updatedEpisode?.posterImageURL = updatedShow?.imagePosterURL
                                    }
                                }
                                completion?(error, nil, updatedEpisode)
                            })
                        } else {
                            completion?(error, nil, updatedEpisode)
                        }
                    })
                    //                }
                } else {
                    completion?(nil, nil, nil)
                }
            } catch let jsonError {
                completion?(jsonError, nil, nil)
            }
        }) { (error) in
            //Boo
            KrangLogger.log.error("Error getting currently watching movie or episode: \(error)")
            completion?(error, nil, nil)
        }
    }
    
    func getAllSeasons(forShow show: KrangShow, completion: ((Error?, KrangShow?) -> ())?) {
        let url = String(format: Constants.traktGetShowSeasonsURLFormat, show.slug)
        let _ = self.oauth.client.get(url, parameters: [:], headers: TraktHelper.defaultHeaders(), success: { (response) in
            //Success
            do {
                let json = try JSON(data: response.data)
                
                if let seasonDics = json.array {
                    RealmManager.makeChanges {
                        for seasonDic in seasonDics {
                            guard let traktID = seasonDic["ids"]["trakt"].int else {
                                continue
                            }
                            
                            let season: KrangSeason = {
                                if let existingSeason = KrangSeason.with(traktID: traktID) {
                                    existingSeason.update(withJSON: seasonDic)
                                    return existingSeason
                                } else {
                                    let newSeason = KrangSeason()
                                    newSeason.update(withJSON: seasonDic)
                                    newSeason.saveToDatabaseOutsideWriteTransaction()
                                    return newSeason
                                }
                            }()
                            season.show = show
                        }
                    }
                }
                
                let imageUpdateGroup = DispatchGroup()
                show.seasons.filter { $0.posterImageURL == nil }.forEach {
                    if !TraktHelper.asyncImageLoadingOnSearch {
                        imageUpdateGroup.enter()
                    }
                    TMDBHelper.shared.update(season: $0, completion: { (imageError, updatedSeason) in
                        if !TraktHelper.asyncImageLoadingOnSearch {
                            imageUpdateGroup.leave()
                        }
                    })
                }
                imageUpdateGroup.notify(queue: DispatchQueue.main) {
                    completion?(nil, show)
                }
            } catch let jsonError {
                completion?(jsonError, show)
            }
        }) { (error) in
            //Failure
            completion?(error, show)
        }
    }
    
    func getAllSeasonsAndEpisodes(forShow show: KrangShow, completion: ((Error?, KrangShow?) -> ())?) {
        let url = String(format: Constants.traktGetShowSeasonsAndEpisodesURLFormat, show.slug)
        let _ = self.oauth.client.get(url, parameters: [:], headers: TraktHelper.defaultHeaders(), success: { (response) in
            do {
                let json = try JSON(data: response.data)
                if let showDics = json.array {
                    RealmManager.makeChanges {
                        showDics.forEach {
                            let thisJSON  = $0
                            
                            guard let seasonNumber = thisJSON["number"].int else {
                                return
                            }
                            
                            let season: KrangSeason = {
                                if let existingSeason = show.getSeason(withSeasonNumber: seasonNumber) {
                                    existingSeason.update(withJSON: thisJSON)
                                    return existingSeason
                                } else {
                                    let newSeason = KrangSeason()
                                    newSeason.update(withJSON: thisJSON)
                                    newSeason.saveToDatabaseOutsideWriteTransaction()
                                    return newSeason
                                }
                            }()
                            season.show = show
                            
                            if let episodeDics = thisJSON["episodes"].array {
                                episodeDics.forEach {
                                    let episodeJSON = $0
                                    guard let episodeID = episodeJSON["ids"]["trakt"].int else {
                                        return
                                    }
                                    
                                    var jsonForUpdating = JSON(["type": "episode"])
                                    jsonForUpdating["episode"] = episodeJSON
                                    
                                    let episode: KrangEpisode = {
                                        if let existingEpisode = KrangEpisode.with(traktID: episodeID) {
                                            existingEpisode.update(withJSON: jsonForUpdating)
                                            return existingEpisode
                                        } else {
                                            let newEpisode = KrangEpisode()
                                            newEpisode.update(withJSON: jsonForUpdating)
                                            newEpisode.saveToDatabaseOutsideWriteTransaction()
                                            return newEpisode
                                        }
                                    }()
                                    
                                    episode.season = season
                                    episode.show = show
                                }
                            }
                        }
                    }
                }
                completion?(nil, show)
            } catch let jsonError {
                completion?(jsonError, show)
            }
        }) { (error) in
            //Error
            completion?(error, show)
        }
    }
    
    func getAllEpisodes(forSeason season: KrangSeason, completion: ((Error?, KrangSeason?) -> ())?) {
        //@TODO
        guard let show = season.show else {
            completion?(NSError(domain: "Krang", code: -1, userInfo: ["debugMessage": "no show for season"]), season)
            return
        }
        
        let url = String(format: Constants.traktGetEpisodesForSeasonURLFormat, show.slug, season.seasonNumber)
        let _ = self.oauth.client.get(url, parameters: [:], headers: TraktHelper.defaultHeaders(), success: { (response) in
            //Success
            do {
                let json = try JSON(data: response.data)
                var theseEpisodes = [KrangEpisode]()
                if let episodeDics = json.array {
                    RealmManager.makeChanges {
                        for episodeDic in episodeDics {
                            guard let traktID = episodeDic["ids"]["trakt"].int else {
                                continue
                            }
                            var jsonForUpdating = JSON(["type": "episode"])
                            jsonForUpdating["episode"] = episodeDic
                            let episode: KrangEpisode = {
                                if let existingEpisode = KrangEpisode.with(traktID: traktID) {
                                    existingEpisode.update(withJSON: jsonForUpdating)
                                    return existingEpisode
                                } else {
                                    let newEpisode = KrangEpisode()
                                    newEpisode.update(withJSON: jsonForUpdating)
                                    newEpisode.saveToDatabaseOutsideWriteTransaction()
                                    return newEpisode
                                }
                            }()
                            episode.season = season
                            episode.show = show
                            theseEpisodes.append(episode)
                        }
                    }
                    
                    //Update images
                    let imageUpdateGroup = DispatchGroup()
                    theseEpisodes.filter { $0.stillImageURL == nil || $0.stillImageURLs.isEmpty }.forEach {
                        if !TraktHelper.asyncImageLoadingOnSearch {
                            imageUpdateGroup.enter()
                        }
                        TMDBHelper.shared.update(episode: $0, completion: { (error, updatedEpisode) in
                            if !TraktHelper.asyncImageLoadingOnSearch {
                                imageUpdateGroup.leave()
                            }
                        })
                    }
                    imageUpdateGroup.notify(queue: DispatchQueue.main) {
                        completion?(nil, season)
                    }
                }
            } catch let jsonError {
                completion?(jsonError, season)
            }
        }) { (error) in
            //Failure
            completion?(error, season)
        }
    }
    
    func getExtendedInfo(forMovie movie: KrangMovie, completion:((Error?, KrangMovie) -> ())?) {
        let url = String(format:Constants.traktGetMovieExtendedInfoFormat, movie.traktID)
        let _ = self.oauth.client.get(url, parameters: [:], headers: TraktHelper.defaultHeaders(), success: { (response) in
            do {
                let json = try JSON(data: response.data)
                var jsonForUpdating = JSON()
                jsonForUpdating["type"] = "movie"
                jsonForUpdating["movie"] = json
                movie.makeChanges {
                    movie.update(withJSON: jsonForUpdating)
                }
                completion?(nil, movie)
            } catch let jsonError {
                completion?(jsonError, movie)
            }
        }) { (error) in
            completion?(error, movie)
        }
    }
    
    //MARK:- Marking
    func markWatched(_ watchable: KrangWatchable, completion: ((Error?) -> ())?) {
        let url = Constants.traktMarkWatchedURL
        var params: [String: Any] = [:]
        switch watchable {
        case is KrangMovie:
            params["movies"] = [["ids": ["trakt": watchable.traktID]]]
        case is KrangEpisode:
            params["episodes"] = [["ids": ["trakt": watchable.traktID]]]
        default:
            break
        }
        let watchedAt = Date()
        params["watched_at"] = watchedAt.toUTCTimestamp()
        let _ = self.oauth.client.post(url, parameters: params, headers: TraktHelper.defaultHeaders(), body: nil, success: { (response) in
            RealmManager.makeChanges {
                watchable.watchDate = watchedAt
            }
            completion?(nil)
        }) { (error) in
            completion?(error)
        }
    }
    
    //MARK:- Marking
    func markUnwatched(_ watchable: KrangWatchable, completion: ((Error?) -> ())?) {
        let url = Constants.traktMarkUnwatchedURL
        var params: [String: Any] = [:]
        switch watchable {
        case is KrangMovie:
            params["movies"] = [["ids": ["trakt": watchable.traktID]]]
        case is KrangEpisode:
            params["episodes"] = [["ids": ["trakt": watchable.traktID]]]
        default:
            break
        }
        let _ = self.oauth.client.post(url, parameters: params, headers: TraktHelper.defaultHeaders(), body: nil, success: { (response) in
            RealmManager.makeChanges {
                watchable.watchDate = nil
            }
            completion?(nil)
        }) { (error) in
            completion?(error)
        }
    }
    
    //MARK:- History Sync
    func getFullHistory(since date: Date, page: Int = 1, progress: ((Int, Int) -> ())?, completion: ((Error?) -> ())?, showIDsSoFar: [Int] = []) {
        let url = Constants.traktGetHistory
        var showIDs = [Int]()
        showIDs.append(contentsOf: showIDsSoFar)
        let _ = self.oauth.client.get(url, parameters: ["start_at": date, "limit": 500, "page": page], headers: TraktHelper.defaultHeaders(), success: { (response) in
            //Success
            guard let szPageCount = response.response.allHeaderFields["x-pagination-page-count"] as? String, let szCurrentPage = response.response.allHeaderFields["x-pagination-page"] as? String, let pageCount = Int(szPageCount), let currentPage = Int(szCurrentPage) else {
                //@TODO: Error
                completion?(nil)
                return
            }
            do {
                let json = try JSON(data: response.data)
                var parsedShows = [Int: KrangShow]()
                let parsingGroup = DispatchGroup()
                parsingGroup.enter()
                
                if let dics = json.array {
                    let showDics = dics.filter { $0["show"]["ids"]["trakt"].int != nil }
                    let episodeDics = dics.filter { $0["episode"]["ids"]["trakt"].int != nil }
                    let movieDics = dics.filter { $0["movie"]["ids"]["trakt"].int != nil }
                    //First do the shows
                    
                    let showsGroup = DispatchGroup()
                    showsGroup.enter()
                    RealmManager.makeChanges {
                        showDics.forEach {
                            guard let szWatchedAt = $0["watched_at"].string, let watchedAt = Date.from(utcTimestamp: szWatchedAt) else {
                                return
                            }
                            
                            let thisJSON = $0["show"]
                            guard let showID = thisJSON["ids"]["trakt"].int else {
                                return
                            }
                            if showIDs.contains(showID) {
                                return
                            }
                            
                            let show: KrangShow = {
                                if let existingShow = KrangShow.with(traktID: showID) {
                                    existingShow.update(withJSON: thisJSON)
                                    return existingShow
                                } else {
                                    let newShow = KrangShow()
                                    newShow.update(withJSON: thisJSON)
                                    newShow.saveToDatabaseOutsideWriteTransaction()
                                    return newShow
                                }
                            }()
                            show.setLastWatchDateIfNewer(watchedAt)
                            parsedShows[showID] = show
                            if !showIDs.contains(showID) {
                                showIDs.append(showID)
                            }
                            
                            showsGroup.enter()
                            self.getAllSeasons(forShow: show, completion: { (_, _) in
                                showsGroup.leave()
                            })
                        }
                    }
                    showsGroup.leave()
                    showsGroup.notify(queue: DispatchQueue.global(qos: DispatchQoS.background.qosClass), execute: {
                        KrangLogger.log.debug("Finished parsing shows for page \(currentPage) of \(pageCount).")
                        RealmManager.makeChanges {
                            episodeDics.forEach {
                                guard let szWatchedAt = $0["watched_at"].string, let watchedAt = Date.from(utcTimestamp: szWatchedAt) else {
                                    return
                                }
                                let thisJSON = $0
                                if let episodeID = $0["episode"]["ids"]["trakt"].int {
                                    let episode: KrangEpisode = {
                                        if let existingEpisode = KrangEpisode.with(traktID: episodeID) {
                                            existingEpisode.update(withJSON: thisJSON)
                                            return existingEpisode
                                        } else {
                                            let newEpisode = KrangEpisode()
                                            newEpisode.update(withJSON: thisJSON)
                                            newEpisode.saveToDatabaseOutsideWriteTransaction()
                                            return newEpisode
                                        }
                                    }()
                                    episode.watchDate = watchedAt
                                    if let showID = $0["show"]["ids"]["trakt"].int, let show = (KrangShow.with(traktID: showID) ?? parsedShows[showID]){
                                        episode.show = show
                                        if let season = show.getSeason(withSeasonNumber: episode.seasonNumber), !season.episodes.contains(episode) {
                                            episode.season = season
                                        }
                                        show.setLastWatchDateIfNewer(watchedAt)
                                    }
                                }
                            }
                        }
                        parsingGroup.leave()
                    })
                    
                    //Movies
                    parsingGroup.enter()
                    RealmManager.makeChanges {
                        movieDics.forEach {
                            guard let szWatchedAt = $0["watched_at"].string, let watchedAt = Date.from(utcTimestamp: szWatchedAt) else {
                                return
                            }
                            
                            let thisJSON = $0
                            guard let movieID = $0["movie"]["ids"]["trakt"].int else {
                                return
                            }
                            let movie: KrangMovie = {
                                if let existingMovie = KrangMovie.with(traktID: movieID) {
                                    existingMovie.update(withJSON: thisJSON)
                                    return existingMovie
                                } else {
                                    let newMovie = KrangMovie()
                                    newMovie.update(withJSON: thisJSON)
                                    newMovie.saveToDatabaseOutsideWriteTransaction()
                                    return newMovie
                                }
                            }()
                            movie.watchDate = watchedAt
                        }
                    }
                }
                
                parsingGroup.leave()
                if currentPage < pageCount {
                    progress?(currentPage, pageCount)
                    self.getFullHistory(since: date, page: (currentPage + 1), progress: progress, completion: completion, showIDsSoFar: showIDs)
                } else {
                    parsingGroup.notify(queue: DispatchQueue.main, execute: {
                        completion?(nil)
                    })
                }
            } catch let jsonError {
                completion?(jsonError)
            }
        }) { (error) in
            //Failure
            completion?(error)
        }
    }
    
    func getHistory(forShow show: KrangShow, completion: ((Error?, KrangShow) -> ())?) {
        let url = String(format: Constants.traktGetShowHistoryFormat, show.traktID)
        //@TODO: Pagination?
        let _ = self.oauth.client.get(url, parameters: ["limit":Int.max], headers: TraktHelper.defaultHeaders(), success: { (response) in
            //Yay
            do {
                let json = try JSON(data: response.data)
                if let episodeDics = json.array {
                    RealmManager.makeChanges {
                        let watchedEpisodeIDs = episodeDics.filter { $0["episode"]["ids"]["trakt"].int != nil }.map { $0["episode"]["ids"]["trakt"].int! }
                        let unwatchedEpisodes = show.episodes.filter { watchedEpisodeIDs.contains($0.traktID) }
                        unwatchedEpisodes.forEach { $0.watchDate = nil }
                        episodeDics.forEach {
                            guard let traktID = $0["episode"]["ids"]["trakt"].int,
                                let szWatchedAt = $0["watched_at"].string,
                                let watchedAt = Date.from(utcTimestamp: szWatchedAt) else {
                                    return
                            }
                            
                            let thisJSON = $0
                            let episode: KrangEpisode = {
                                if let existingEpisode = KrangEpisode.with(traktID: traktID)  {
                                    return existingEpisode
                                } else {
                                    //                                KrangLogger.log.error("Couldn't find episode \(traktID)")
                                    let newEpisode = KrangEpisode()
                                    newEpisode.update(withJSON: thisJSON)
                                    newEpisode.saveToDatabaseOutsideWriteTransaction()
                                    return newEpisode
                                }
                            }()
                            
                            episode.show = show
                            if let season = show.getSeason(withSeasonNumber: episode.seasonNumber) {
                                episode.season = season
                            } else {
                                KrangLogger.log.error("Couldn't find a season for \(episode.titleDisplayString)")
                            }
                            episode.watchDate = watchedAt
                        }
                    }
                }
                completion?(nil, show)
            } catch let jsonError {
                completion?(jsonError, show)
            }
        }) { (error) in
            //Boo
            completion?(error, show)
        }
    }
    
    func getRecentShowHistory(_ completion: ((Error?, [KrangShow]) -> ())?) {
        let url = Constants.traktGetShowHistory
        let now = Date()
        let fourWeeksAgo = Date(timeIntervalSince1970: now.timeIntervalSince1970 - (60.0 * 60.0 * 24.0 * 7.0 * 4.0))
        let _ = self.oauth.client.get(url, parameters: ["start_at": fourWeeksAgo, "limit": 50], headers: TraktHelper.defaultHeaders(), success: { (response) in
            var results = [KrangShow]()
            var showTraktIDs = [Int]()
            do {
                let json = try JSON(data: response.data)
                if let dics = json.array {
                    RealmManager.makeChanges {
                        dics.filter { $0["show"].exists() }.map { $0["show"] }.forEach {
                            guard let traktID = $0["ids"]["trakt"].int else {
                                return
                            }
                            guard !showTraktIDs.contains(traktID) else {
                                return
                            }
                            showTraktIDs.append(traktID)
                            let thisJSON = $0
                            let show: KrangShow = {
                                if let existingShow = KrangShow.with(traktID: traktID) {
                                    existingShow.update(withJSON: thisJSON)
                                    return existingShow
                                } else {
                                    let newShow = KrangShow()
                                    newShow.update(withJSON: thisJSON)
                                    newShow.saveToDatabaseOutsideWriteTransaction()
                                    return newShow
                                }
                            }()
                            results.append(show)
                        }
                    }
                }
                
                let imageUpdateGroup = DispatchGroup()
                results.filter { $0.imagePosterURL == nil }.forEach {
                    if !TraktHelper.asyncImageLoadingOnSearch {
                        imageUpdateGroup.enter()
                    }
                    TMDBHelper.shared.update(show: $0, completion: { (error, updatedShow) in
                        if !TraktHelper.asyncImageLoadingOnSearch {
                            imageUpdateGroup.leave()
                        }
                    })
                }
                imageUpdateGroup.notify(queue: DispatchQueue.main) {
                    completion?(nil, results)
                }
            } catch let jsonError {
                completion?(jsonError, [KrangShow]())
            }
        }) { (error) in
            completion?(error, [KrangShow]())
        }
    }
    
    //MARK:-
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
            do {
                let json = try JSON(data: response.data)
                var result: [KrangSearchable] = []
                if let matchDics = json.array {
                    RealmManager.makeChanges {
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
                            case "show":
                                guard let traktID = $0["show"]["ids"]["trakt"].int else {
                                    return
                                }
                                
                                let thisJSON = $0["show"]
                                let show:KrangShow = {
                                    if let existingShow = KrangShow.with(traktID: traktID) {
                                        existingShow.update(withJSON: thisJSON)
                                        return existingShow
                                    } else {
                                        let newShow = KrangShow()
                                        newShow.update(withJSON: thisJSON)
                                        newShow.saveToDatabaseOutsideWriteTransaction()
                                        return newShow
                                    }
                                }()
                                result.append(show)
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
                    } else if let show = $0 as? KrangShow {
                        if !TraktHelper.asyncImageLoadingOnSearch {
                            imageUpdateGroup.enter()
                        }
                        TMDBHelper.shared.update(show: show, completion: { (_, updatedShow) in
                            if !TraktHelper.asyncImageLoadingOnSearch {
                                imageUpdateGroup.leave()
                            }
                        })
                    }
                }
                imageUpdateGroup.notify(queue: DispatchQueue.main) {
                    completion?(nil, result)
                }
            } catch let jsonError {
                completion?(jsonError, [])
            }
        }) { (error) in
            //Failure
            completion?(error, [])
        }
        
        return request
    }
    
    func checkIn(to watchable: KrangWatchable, completion: ((Error?, KrangWatchable?) -> ())?) {
        self._cancelAllCheckins() { cancelError in
            let url = Constants.traktCheckInURL
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
                    NotificationCenter.default.post(name: Notification.Name.didCheckInToWatchable, object: watchable, userInfo: nil)
                }
            }) { (error) in
                //Failure
                completion?(error, nil)
            }
        }
    }
    
    func cancelAllCheckins(_ completion: ((Error?) -> ())? ) {
        self._cancelAllCheckins { (error) in
            if error == nil {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name.didCheckInToWatchable, object: nil, userInfo: nil)
                }
            }
            completion?(error)
        }
    }
    
    private func _cancelAllCheckins(_ completion: ((Error?) -> ())? ) {
        let url = Constants.traktCheckInURL
        let _ = self.oauth.client.delete(url, parameters: [:], headers: TraktHelper.defaultHeaders(), success: { (_) in
            completion?(nil)
        }) { (error) in
            completion?(error)
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
        RealmManager.makeChanges {
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
                    
                    episode.show = show
                    if let season = show.getSeason(withSeasonNumber: episode.seasonNumber) {
                        episode.season = season
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
