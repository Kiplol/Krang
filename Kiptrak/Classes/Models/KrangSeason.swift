//
//  KrangSeason.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 9/15/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class KrangSeason: Object {
    
    private static let placeholderTitle = "Season"
    
    @objc dynamic var numberOfAiredEpisodes:Int = 0
    @objc dynamic var seasonNumber:Int = -1
    @objc dynamic var title:String = KrangSeason.placeholderTitle
    @objc dynamic var traktID: Int = -1
    @objc dynamic var imdbID: String? = nil
    @objc dynamic var tmdbID: Int = -1
    @objc dynamic var tvRageID: Int = -1
    @objc dynamic var posterImageURL: String? = nil
    @objc dynamic var show: KrangShow? = nil
    let episodes = LinkingObjects(fromType: KrangEpisode.self, property: "season")
    
    class func with(traktID: Int) -> KrangSeason? {
        if traktID == -1 {
            return nil
        }
        let realm = try! Realm()
        let matchingSeasons = realm.objects(KrangSeason.self).filter("traktID = %d", traktID)
        if matchingSeasons.count > 0 {
            return matchingSeasons.first
        }
        return nil
    }
    
    func getEpisodesInOrder() -> Results<KrangEpisode> {
        return self.episodes.sorted(byKeyPath: "episode")
    }
    
    func update(withJSON json:JSON) {
        self.traktID = json["ids"]["trakt"].int ?? -1
        self.imdbID = json["ids"]["imdb"].string
        self.tmdbID = json["ids"]["tmdb"].int ?? -1
        self.tvRageID = json["ids"]["tvrage"].int ?? -1
        self.title = json["title"].string ?? KrangSeason.placeholderTitle
        self.seasonNumber = json["number"].int ?? -1
        self.numberOfAiredEpisodes = json["aired_episodes"].int ?? self.numberOfAiredEpisodes
    }
    
    func unseenEpisodes() -> Results<KrangEpisode> {
        let matches = self.episodes.filter("watchDate == nil")
        return matches
    }
    
    func hasUnseenEpisodes() -> Bool {
        guard !self.episodes.isEmpty else {
            return true
        }
        let hasThem = self.episodes.count - self.unseenEpisodes().count < self.numberOfAiredEpisodes
        return hasThem
    }
    
    func hasBeenWatched() -> Bool {
        return !self.hasUnseenEpisodes() && self.numberOfAiredEpisodes > 0
    }
    
    class func deleteAllSeasons() {
        let realm = try! Realm()
        let allSeasons = realm.objects(KrangSeason.self)
        realm.delete(allSeasons)
    }

}
