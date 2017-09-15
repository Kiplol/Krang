//
//  TMDBHelper.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/11/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit
import OAuthSwift
import SwiftyJSON
import RealmSwift

class TMDBHelper: NSObject {

    static let shared = TMDBHelper()
    let oauth = OAuth2Swift(consumerKey: "", consumerSecret: "", authorizeUrl: "", responseType: "")
    var gotConfiguration = false
    var configuration = TMDBHelper.Configuration()
    
    func getConfiguration(completion:((_:Error?) -> ())?) {
        let _ = self.oauth.client.get(Constants.tmdbConfigurationURL, success: { (response) in
            //Yay
            let json = JSON(data: response.data)
            self.configuration = Configuration()
            self.configuration.update(with: json)
            self.gotConfiguration = true
            completion?(nil)
        }) { (error) in
            //Boo
            completion?(error)
        }
    }
    
    func update(movie:KrangMovie, completion:((_:Error?, _:KrangMovie?) -> ())?, outsideOfWriteTransaction: Bool = false) {
        guard movie.tmdbID != -1 else {
            completion?(nil, movie)
            return
        }
        let url = String(format: Constants.tmdbMovieGetURLFormat, movie.tmdbID)
        let _ = self.oauth.client.get(url, success: { (response) in
            //Yay
            let json = JSON(data: response.data)
            if outsideOfWriteTransaction {
                self.update(movie: movie, OutsideOfWriteTransactionWithJSON: json)
            } else {
                self.update(movie: movie, withJSON: json)
            }
            completion?(nil, movie)
        }) { (error) in
            //Boo
            completion?(error, movie)
        }
    }
    
    func update(episode:KrangEpisode, completion:((_:Error?, _:KrangEpisode?) -> ())?) {
        guard episode.tmdbID != -1 else {
            completion?(nil, episode)
            return
        }
        
        guard let show = episode.show else {
            completion?(nil, episode)
            return
        }
        
        guard show.tmdbID != -1 else {
            completion?(nil, episode)
            return
        }
        
        KrangLogger.log.debug("Updating episode")
        let url = String(format: Constants.tmdbEpisodeGetURLFormat, show.tmdbID, show.slug, episode.season, episode.episode)
        let _ = self.oauth.client.get(url, success: { (response) in
            let json = JSON(data: response.data)
            self.update(episode: episode, withJSON: json)
            
            KrangLogger.log.debug("Updated episode with episode details.  Now updating with season details.")
            let seasonURL = String(format: Constants.tmdbSeasonGetURLFormat, show.tmdbID, show.slug, episode.season)
            let _ = self.oauth.client.get(seasonURL, success: { (seasonResponse) in
                let seasonJSON = JSON(data: seasonResponse.data)
                self.update(episode: episode, withSeasonJSON: seasonJSON)
                completion?(nil, episode)
            }, failure: { (seasonError) in
                KrangLogger.log.error("Error updating episode with season data.  Error: \(seasonError)\nEpisode: \(episode)")
                completion?(seasonError, episode)
            })
            
        }) { (error) in
            KrangLogger.log.error("Error updating episode.  Error: \(error)\nEpisode: \(episode)")
            completion?(error, episode)
        }
    }
    
    func update(show:KrangShow, completion:((_:Error?, _:KrangShow?) -> ())?) {
        guard show.tmdbID != -1 else {
            completion?(NSError(domain: "Krang", code: -1, userInfo: ["debugMessage": "tmdbID = -1"]), show)
            return
        }
        
        KrangLogger.log.debug("Updating show")
        let url = String(format: Constants.tmdbShowGetURLFormat, show.tmdbID, show.slug)
        let _ = self.oauth.client.get(url, success: { (response) in
            //Success
            let showJSON = JSON(data: response.data)
            self.update(show: show, withJSON: showJSON)
            completion?(nil, show)
        }) { (error) in
            //Faliure
            completion?(error, show)
        }
    }
    
    class Configuration {
        var imageBaseURL = ""
        var posterSizes: [String] = [""]
        var backdropSizes: [String] = [""]
        var logoSizes: [String] = [""]
        var profileSizes: [String] = [""]
        var stillSizes: [String] = [""]
        
        func update(with json:JSON) {
            self.imageBaseURL = json["images"]["secure_base_url"].string ?? ""
            self.posterSizes = json["images"]["poster_sizes"].arrayObject as? [String] ?? [""]
            self.stillSizes = json["images"]["still_sizes"].arrayObject as? [String] ?? [""]
            self.backdropSizes = json["images"]["backdrop_sizes"].arrayObject as? [String] ?? [""]
        }
    }
    
    private func update(movie:KrangMovie, withJSON json:JSON) {
        movie.makeChanges {
            self.update(movie: movie, OutsideOfWriteTransactionWithJSON: json)
        }
    }
    
    private func update(movie:KrangMovie, OutsideOfWriteTransactionWithJSON json:JSON) {
        if let posterPath = json["poster_path"].string, self.configuration.posterSizes.count > 0 {
            let posterURL = self.configuration.imageBaseURL + self.configuration.posterSizes[Int(3 * self.configuration.posterSizes.count / 4)] + posterPath
            movie.posterImageURL = posterURL
            let smallestPosterURL = self.configuration.imageBaseURL + self.configuration.posterSizes[0] + posterPath
            movie.posterThumbnailImageURL = smallestPosterURL
        }
        
        if let stillPath = json["backdrop_path"].string, self.configuration.backdropSizes.count > 0 {
            let backdropURL = self.configuration.imageBaseURL + self.configuration.backdropSizes[Int(3 * self.configuration.backdropSizes.count / 4)] + stillPath
            let smallestBackdropURL = self.configuration.imageBaseURL + self.configuration.backdropSizes[0] + stillPath
            movie.backdropImageURL = backdropURL
            movie.backdropThumbnailImageURL = smallestBackdropURL
        }
    }
    
    private func update(episode:KrangEpisode, withJSON json:JSON) {
        episode.makeChanges {
            if let stillPath = json["still_path"].string, self.configuration.stillSizes.count > 0 {
                let stillURL = self.configuration.imageBaseURL + self.configuration.stillSizes[Int(3 * self.configuration.stillSizes.count / 4)] + stillPath
                let smallestStillURL = self.configuration.imageBaseURL + self.configuration.stillSizes[0] + stillPath
                episode.stillImageURL = stillURL
                episode.stillThumbnailImageURL = smallestStillURL
            }
        }
    }
    
    private func update(episode:KrangEpisode, withSeasonJSON json:JSON) {
        episode.makeChanges {
            if let posterPath = json["poster_path"].string, self.configuration.posterSizes.count > 0 {
                let posterURL = self.configuration.imageBaseURL + self.configuration.posterSizes[Int(3 * self.configuration.posterSizes.count / 4)] + posterPath
                let smallestPosterURL = self.configuration.imageBaseURL + self.configuration.posterSizes[0] + posterPath
                
                let realmStringURLs = self.configuration.posterSizes.map({ sizeString in
                    self.configuration.imageBaseURL + sizeString + posterPath
                }).map({ fullURL in
                    RealmString.with(value: fullURL)
                })
                
                episode.posterImageURL = posterURL
                episode.posterThumbnailImageURL = smallestPosterURL
                episode.posterImageURLs = List<RealmString>(realmStringURLs)
            }
        }
    }
    
    private func update(show: KrangShow, withJSON json: JSON) {
        show.makeChanges {
            if let posterPath = json["poster_path"].string, self.configuration.posterSizes.count > 0 {
                let posterURL = self.configuration.imageBaseURL + self.configuration.posterSizes[Int(3 * self.configuration.posterSizes.count / 4)] + posterPath
                
                let realmStringURLs = self.configuration.posterSizes.map({ sizeString in
                    self.configuration.imageBaseURL + sizeString + posterPath
                }).map({ fullURL in
                    RealmString.with(value: fullURL)
                })
                
                show.imagePosterURL = posterURL
                show.imagePosterURLs = List<RealmString>(realmStringURLs)
            }
        }
    }
    
}
