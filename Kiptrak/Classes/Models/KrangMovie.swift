//
//  KrangMovie.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/11/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class KrangMovie: Object {
    
    private static let placeholderUnknown = "Unknown"
    
    dynamic var title: String = KrangMovie.placeholderUnknown
    dynamic var year: Int = -1
    dynamic var traktID: Int = -1
    dynamic var slug: String = ""
    dynamic var imdbID: String? = nil
    dynamic var tmdbID: Int = -1
    dynamic var posterImageURL: String? = nil
    dynamic var posterThumbnailImageURL: String? = nil
    dynamic var backdropImageURL:String? = nil
    dynamic var backdropThumbnailImageURL: String? = nil
    
    func update(withJSON json:JSON) {
        guard let type = json["type"].string else {
            return
        }
        
        guard type == "movie" else {
            return
        }
        
        self.title = json["movie"]["title"].string ?? KrangMovie.placeholderUnknown
        self.year = json["movie"]["year"].int ?? -1
        self.traktID = json["movie"]["ids"]["trakt"].int ?? -1
        self.slug = json["movie"]["ids"]["slug"].string ?? ""
        self.imdbID = json["movie"]["ids"]["imdb"].string
        self.tmdbID = json["movie"]["ids"]["tmdb"].int ?? -1
    }
    
    class func with(traktID:Int) -> KrangMovie? {
        let realm = try! Realm()
        let matchingMovies = realm.objects(KrangMovie.self).filter("traktID = %d", traktID)
        if matchingMovies.count > 0 {
            return matchingMovies.first
        }
        return nil
    }
    
    class func from(json:JSON) -> KrangMovie? {
        guard let type = json["type"].string else {
            return nil
        }
        
        guard type == "movie" else {
            return nil
        }
        
        guard let traktID = json["movie"]["ids"]["trakt"].int else {
            return nil
        }
        
        let movie:KrangMovie = {
            if let existingMovie = KrangMovie.with(traktID: traktID) {
                return existingMovie
            } else {
                return KrangMovie()
            }
        }()
        
        movie.update(withJSON: json)
        return movie
    }
    
    func urlForIMDB() -> URL? {
        guard let imdbID = self.imdbID else {
            return nil
        }
        
        let szURL = String(format: Constants.imdbURLFormat, imdbID)
        return URL(string: szURL)
    }
}

extension KrangMovie: KrangWatchable {
    var titleDisplayString: String {
        get {
            return self.title
        }
    }
    
    var posterThumbnailURL: URL? {
        get {
            guard let posterThumbnailURL = self.posterThumbnailImageURL else {
                return nil
            }
            return URL(string: posterThumbnailURL)
        }
    }
}
