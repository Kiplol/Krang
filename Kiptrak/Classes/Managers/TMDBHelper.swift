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
    
}
