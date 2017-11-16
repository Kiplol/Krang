//
//  KrangEpisode.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/12/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class KrangEpisode: Object {
    
    private static let placeholderUnknown = "Unknown"
    
    @objc dynamic var episode:Int = -1
    @objc dynamic var absoluteEpisodeNumber:Int = -1
    @objc dynamic var seasonNumber:Int = -1
    @objc dynamic var title:String = KrangEpisode.placeholderUnknown
    @objc dynamic var overview: String = KrangEpisode.placeholderUnknown
    @objc dynamic var traktID: Int = -1
    @objc dynamic var imdbID: String? = nil
    @objc dynamic var tmdbID: Int = -1
    @objc dynamic var tvRageID: Int = -1
    @objc dynamic var posterImageURL: String? = nil
    @objc dynamic var posterThumbnailImageURL: String? = nil
    var posterImageURLs: List<RealmString> = List<RealmString>()
    @objc dynamic var stillImageURL: String? = nil
    var stillImageURLs: List<RealmString> = List<RealmString>()
    @objc dynamic var stillThumbnailImageURL: String? = nil
    @objc dynamic var checkin:KrangCheckin? = nil
    @objc dynamic var originalJSONString: String = ""
    @objc dynamic var watchDate: Date? = nil
    @objc dynamic var airDate: Date? = nil
    @objc dynamic var show: KrangShow? = nil
    @objc dynamic var season: KrangSeason? = nil
    
    func update(withJSON json:JSON) {
        guard let type = json["type"].string else {
            return
        }
        
        guard type == "episode" else {
            return
        }
        
        self.originalJSONString = json.rawString() ?? ""
        
        self.episode = json["episode"]["number"].int ?? -1
        self.absoluteEpisodeNumber = json["episode"]["number_abs"].int ?? -1
        self.seasonNumber = json["episode"]["season"].int ?? -1
        self.title = json["episode"]["title"].string ?? KrangEpisode.placeholderUnknown
        self.traktID = json["episode"]["ids"]["trakt"].int ?? -1
        self.imdbID = json["episode"]["ids"]["imdb"].string
        self.tmdbID = json["episode"]["ids"]["tmdb"].int ?? -1
        self.tvRageID = json["episode"]["ids"]["tvrage"].int ?? -1
        self.overview = json["episode"]["overview"].string ?? self.overview
        if let szFirstAired = json["episode"]["first_aired"].string, let firstAired = Date.from(utcTimestamp: szFirstAired) {
            self.airDate = firstAired
        }
        
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
    
    class var allWatchedEpisodes: Results<KrangEpisode> {
        let realm = try! Realm()
        return realm.objects(KrangEpisode.self).filter("watchDate != nil")
    }
    
    class func with(traktID:Int) -> KrangEpisode? {
        if traktID == -1 {
            return nil
        }
        let realm = try! Realm()
        let matchingEpisodes = realm.objects(KrangEpisode.self).filter("traktID = %d", traktID)
        if matchingEpisodes.count > 0 {
            return matchingEpisodes.first
        }
        return nil
    }
    
    class func from(json:JSON) -> KrangEpisode? {
        guard let type = json["type"].string else {
            return nil
        }
        
        guard type == "episode" else {
            return nil
        }
        
        guard let traktID = json["episode"]["ids"]["trakt"].int else {
            return nil
        }
        
        let episode:KrangEpisode = {
            if let existingEpisode = KrangEpisode.with(traktID: traktID) {
                return existingEpisode
            } else {
                return KrangEpisode()
            }
        }()
        
        episode.update(withJSON: json)
        return episode
    }
    
    class func deleteAllEpisodes() {
        let realm = try! Realm()
        let allEpisodes = realm.objects(KrangEpisode.self)
        realm.delete(allEpisodes)
    }
    
    class func removeAllWatchDates() {
        KrangEpisode.allWatchedEpisodes.forEach { $0.watchDate = nil }
    }
}

extension KrangEpisode: KrangWatchable {

    var titleDisplayString: String {
        get {
            if let show = self.show {
                return "\(show.title) - \(self.title)"
            } else {
                return self.title
            }
        }
    }
    
    var subtitle: String {
        return self.airDate != nil ? DateFormatter.localizedString(from: self.airDate!, dateStyle: .medium, timeStyle: .none) : "TBA"
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
            guard let show = self.show else {
                return nil
            }
            
            guard show.tmdbID != -1 else {
                return nil
            }
            
            let szURL = "https://www.themoviedb.org/tv/\(show.tmdbID)-\(show.slug)/season/\(self.seasonNumber)/episode/\(self.episode)"
            return URL(string: szURL)
        }
    }
    
    var urlForTrakt: URL? {
        get {
            guard let show = self.show else {
                return nil
            }
            
            let szURL = "https://www.trakt.tv/shows/\(show.slug)/seasons/\(self.seasonNumber)/episodes/\(self.episode)"
            return URL(string: szURL)
        }
    }
    
    var fanartImageURL: URL? {
        get {
            guard let szURL = self.stillImageURL else {
                return nil
            }
            
            return URL(string: szURL)
        }
    }

    var fanartBlurrableImageURL: URL? {
        get {
            guard let szURL = self.stillThumbnailImageURL else {
                return nil
            }
            
            return URL(string: szURL)
        }
    }
}
