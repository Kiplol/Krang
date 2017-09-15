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
    
    let episodes = List<KrangEpisode>()
    dynamic var seasonNumber:Int = -1
    dynamic var title:String = KrangSeason.placeholderTitle
    dynamic var traktID: Int = -1
    dynamic var imdbID: String? = nil
    dynamic var tmdbID: Int = -1
    dynamic var tvRageID: Int = -1
    dynamic var posterImageURL: String? = nil
    let shows = LinkingObjects(fromType: KrangShow.self, property: "seasons")
    var show: KrangShow? {
        get {
            return self.shows.first
        }
    }
    
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
    
    func update(withJSON json:JSON) {
        self.traktID = json["ids"]["trakt"].int ?? -1
        self.imdbID = json["ids"]["imdb"].string
        self.tmdbID = json["ids"]["tmdb"].int ?? -1
        self.tvRageID = json["ids"]["tvrage"].int ?? -1
        self.title = json["title"].string ?? KrangSeason.placeholderTitle
        self.seasonNumber = json["number"].int ?? -1
    }

}
