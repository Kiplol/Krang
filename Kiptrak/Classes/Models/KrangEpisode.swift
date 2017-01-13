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
    
    dynamic var episode:Int = -1
    dynamic var season:Int = -1
    dynamic var title:String = KrangEpisode.placeholderUnknown
    dynamic var traktID: Int = -1
    dynamic var imdbID: String? = nil
    dynamic var tmdbID: Int = -1
    dynamic var tvRageID: Int = -1
    dynamic var posterImageURL: String? = nil
    let shows = LinkingObjects(fromType: KrangShow.self, property: "episodes")
    var show: KrangShow? {
        get {
            return self.shows.first
        }
    }
    
    func update(withJSON json:JSON) {
        guard let type = json["type"].string else {
            return
        }
        
        guard type == "episode" else {
            return
        }
        
        self.episode = json["episode"]["number"].int ?? -1
        self.season = json["episode"]["season"].int ?? -1
        self.title = json["episode"]["title"].string ?? KrangEpisode.placeholderUnknown
        self.traktID = json["episode"]["ids"]["trakt"].int ?? -1
        self.imdbID = json["episode"]["ids"]["imdb"].string
        self.tmdbID = json["episode"]["ids"]["tmdb"].int ?? -1
        self.tvRageID = json["episode"]["ids"]["tvrage"].int ?? -1
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
    
}
