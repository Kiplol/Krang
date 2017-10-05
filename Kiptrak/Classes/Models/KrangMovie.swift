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
    dynamic var checkin:KrangCheckin? = nil
    dynamic var originalJSONString: String = ""
    dynamic var watchDate: Date? = nil
    
    func update(withJSON json:JSON) {
        guard let type = json["type"].string else {
            return
        }
        
        guard type == "movie" else {
            return
        }
        
        self.originalJSONString = json.rawString() ?? ""
        
        self.title = json["movie"]["title"].string ?? KrangMovie.placeholderUnknown
        self.year = json["movie"]["year"].int ?? -1
        self.traktID = json["movie"]["ids"]["trakt"].int ?? -1
        self.slug = json["movie"]["ids"]["slug"].string ?? ""
        self.imdbID = json["movie"]["ids"]["imdb"].string
        self.tmdbID = json["movie"]["ids"]["tmdb"].int ?? -1
        
        if let szStartedAt = json["started_at"].string,
            let szExpiresAt = json["expires_at"].string,
            let startedAt = Date.from(utcTimestamp: szStartedAt),
            let expiresAt = Date.from(utcTimestamp: szExpiresAt) {
            if let checkin = self.checkin {
                checkin.dateStarted = startedAt
                checkin.dateExpires = expiresAt
            } else {
                self.checkin = KrangCheckin()
                self.checkin?.dateStarted = startedAt
                self.checkin?.dateExpires = expiresAt
                self.checkin?.saveToDatabaseOutsideWriteTransaction()
            }
        } else {
//            if let checkin = self.checkin {
//                checkin.dateStarted = nil
//                checkin.dateStarted = nil
//            }
        }
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
    
    class func deleteAllMovies() {
        let realm = try! Realm()
        let allMovies = realm.objects(KrangMovie.self)
        realm.delete(allMovies)
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
    
    var urlForIMDB: URL? {
        get {
            guard let imdbID = self.imdbID else {
                return nil
            }
            
            let szURL = String(format: Constants.imdbURLFormat, imdbID)
            return URL(string: szURL)
        }
    }
    
    var urlForTMDB: URL? {
        get {
            guard self.tmdbID != -1 else {
                return nil
            }
            
//            https://www.themoviedb.org/movie/174772-europa-report
            
            let szURL = "https://www.themoviedb.org/movie/\(self.tmdbID)-\(self.slug)"
            return URL(string: szURL)
        }
    }
    
    var urlForTrakt: URL? {
        get {
            let szURL = "https://trakt.tv/movies/\(self.slug)"
            return URL(string: szURL)
        }
    }
    
    var fanartImageURL: URL? {
        get {
            guard let szURL = self.backdropImageURL else {
                return nil
            }
            
            return URL(string: szURL)
        }
    }
    
    var fanartBlurrableImageURL: URL? {
        get {
            guard let szURL = self.backdropImageURL else {
                return nil
            }
            
            return URL(string: szURL)
        }
    }
}

extension KrangMovie: KrangSearchable {
    
    var urlForSearchResultThumbnailImage: URL? { return self.posterThumbnailURL }
    var titleForSearchResult: String? { return self.title }
    var subtitleForSearchResult: String? {
        if self.year > -1 {
            return "\(self.year)"
        }
        return nil
    }
    
}
