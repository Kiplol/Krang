//
//  KrangShow.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/12/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class KrangShow: Object {
    
    private static let placeholderUnknown = "Unknown"
    
    let episodes = List<KrangEpisode>()
    let seasons = List<KrangSeason>()
    dynamic var title:String = KrangShow.placeholderUnknown
    dynamic var year:Int = -1
    dynamic var traktID: Int = -1
    dynamic var slug: String = ""
    dynamic var imdbID: String? = nil
    dynamic var tmdbID: Int = -1
    dynamic var tvRageID: Int = -1
    dynamic var imageBackdropURL: String? = nil
    dynamic var imagePosterURL: String? = nil
    var imagePosterURLs: List<RealmString> = List<RealmString>()
    dynamic var overview: String = ""
    
    class func with(traktID: Int) -> KrangShow? {
        if traktID == -1 {
            return nil
        }
        let realm = try! Realm()
        let matchingShows = realm.objects(KrangShow.self).filter("traktID = %d", traktID)
        if matchingShows.count > 0 {
            return matchingShows.first
        }
        return nil
    }
    
    func update(withJSON json:JSON) {
        self.title = json["title"].string ?? KrangShow.placeholderUnknown
        self.year = json["year"].int ?? -1
        self.traktID = json["ids"]["trakt"].int ?? -1
        self.slug = json["ids"]["slug"].string ?? ""
        self.imdbID = json["ids"]["imdb"].string
        self.tmdbID = json["ids"]["tmdb"].int ?? -1
        self.tvRageID = json["ids"]["tvrage"].int ?? -1
    }
    
    func getSeason(withSeasonNumber number: Int) -> KrangSeason? {
        for season in self.seasons {
            if season.seasonNumber == number {
                return season
            }
        }
        return nil
    }
}

extension KrangShow: KrangLinkable {
    var urlForIMDB: URL? {
        guard let imdbID = self.imdbID else {
            return nil
        }
        
        let szURL = String(format: Constants.imdbURLFormat, imdbID)
        return URL(string: szURL)
    }
    
    var urlForTMDB: URL? {
        guard self.tmdbID != -1 else {
            return nil
        }
        
        let szURL = "https://www.themoviedb.org/movie/\(self.tmdbID)-\(self.slug)"
        return URL(string: szURL)
    }
    
    var urlForTrakt: URL? {
        let szURL = "https://trakt.tv/movies/\(self.slug)"
        return URL(string: szURL)
    }
}

extension KrangShow: KrangSearchable {
    
    //@TODO: Thumbnails
    var urlForSearchResultThumbnailImage: URL? {
        if let szURL = self.imagePosterURL {
            return URL(string: szURL)
        }
        return nil
    }
    var titleForSearchResult: String? { return self.title }
    var subtitleForSearchResult: String? {
        if self.year > -1 {
            return "\(self.year)"
        }
        return nil
    }
    
}
