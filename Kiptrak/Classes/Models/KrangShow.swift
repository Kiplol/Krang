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
    dynamic var title:String = KrangShow.placeholderUnknown
    dynamic var year:Int = -1
    dynamic var traktID: Int = -1
    dynamic var slug: String = ""
    dynamic var imdbID: String? = nil
    dynamic var tmdbID: Int = -1
    dynamic var tvRageID: Int = -1
    
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
}

extension KrangShow: KrangWatchable {
    var posterThumbnailURL: URL? {
        get {
            return nil
        }
    }

    var titleDisplayString: String {
        get {
            return self.title
        }
    }
}
