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
    @objc dynamic var title:String = KrangShow.placeholderUnknown
    @objc dynamic var year:Int = -1
    @objc dynamic var traktID: Int = -1
    @objc dynamic var slug: String = ""
    @objc dynamic var imdbID: String? = nil
    @objc dynamic var tmdbID: Int = -1
    @objc dynamic var tvRageID: Int = -1
    @objc dynamic var imageBackdropURL: String? = nil
    @objc dynamic var imagePosterURL: String? = nil
    @objc dynamic var lastWatchDate: Date? = nil
    @objc dynamic var nextEpisodeForWatchProgress: KrangEpisode? = nil
    var imagePosterURLs: List<RealmString> = List<RealmString>()
    let episodes = LinkingObjects(fromType: KrangEpisode.self, property: "show")
    let seasons = LinkingObjects(fromType: KrangSeason.self, property: "show")
    @objc dynamic var overview: String = ""
    
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
    
    func setLastWatchDateIfNewer(_ date: Date) {
        if let existingDate = self.lastWatchDate {
            if date.compare(existingDate) == .orderedDescending {
                self.lastWatchDate = date
            }
        } else {
            self.lastWatchDate = date
        }
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
    
    class var allWatchedShows: Results<KrangShow> {
        let realm = try! Realm()
        let matchingShows = realm.objects(KrangShow.self).filter("lastWatchDate != nil").sorted(byKeyPath: "lastWatchDate", ascending: false)
        return matchingShows
    }
    
    class func deleteAllShows() {
        let realm = try! Realm()
        let allShows = realm.objects(KrangShow.self)
        realm.delete(allShows)
    }
    
    class func removeAllWatchDates() {
        KrangShow.allWatchedShows.forEach { $0.lastWatchDate = nil }
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
        
        let szURL = "https://www.themoviedb.org/tv/\(self.tmdbID)-\(self.slug)"
        return URL(string: szURL)
    }
    
    var urlForTrakt: URL? {
        let szURL = "https://trakt.tv/shows/\(self.slug)"
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
