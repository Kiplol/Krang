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
    
    class func with(slug:String) -> KrangMovie? {
        return nil
    }
    
    class func from(json:JSON) -> KrangMovie? {
        guard let type = json["type"].string else {
            return nil
        }
        
        guard type == "movie" else {
            return nil
        }
        
        guard let slug = json["movie"]["ids"]["slug"].string else {
            return nil
        }
        
        let movie:KrangMovie = {
            if let existingMovie = KrangMovie.with(slug: slug) {
                return existingMovie
            } else {
                return KrangMovie()
            }
        }()
        
        movie.update(withJSON: json)
        return movie
    }
}
