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
    
    func update(movie:KrangMovie, completion:((_:Error?, _:KrangMovie?) -> ())?) {
        guard movie.tmdbID != -1 else {
            completion?(nil, movie)
            return
        }
        let url = String(format: Constants.tmdbMovieGetURLFormat, movie.tmdbID)
        let _ = self.oauth.client.get(url, success: { (response) in
            //Yay
            let json = JSON(data: response.data)
            self.update(movie: movie, withJSON: json)
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
        
        //TODO
        completion?(nil, show)
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
            if let posterPath = json["poster_path"].string {
                let posterURL = self.configuration.imageBaseURL + self.configuration.posterSizes[Int(3 * self.configuration.posterSizes.count / 4)] + posterPath
                movie.posterImageURL = posterURL
            }
        }
    }
    
    private func update(episode:KrangEpisode, withJSON json:JSON) {
        episode.makeChanges {
            if let stillPath = json["still_path"].string {
                let stillURL = self.configuration.imageBaseURL + self.configuration.stillSizes[Int(3 * self.configuration.stillSizes.count / 4)] + stillPath
                episode.stillImageURL = stillURL
            }
        }
    }
    
    private func update(episode:KrangEpisode, withSeasonJSON json:JSON) {
        episode.makeChanges {
            if let posterPath = json["poster_path"].string {
                let posterURL = self.configuration.imageBaseURL + self.configuration.posterSizes[Int(3 * self.configuration.posterSizes.count / 4)] + posterPath
                episode.posterImageURL = posterURL
            }
        }
    }
    
}
