//
//  KrangUser.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/9/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class KrangUser: Object {
    
    dynamic var username:String = ""
    dynamic var slug:String = ""
    dynamic var name:String? = nil
    dynamic var vip:Bool = false
    dynamic var about:String? = nil
    dynamic var location:String? = nil
    dynamic var gender:String = "male"
    dynamic var avatarImageURL:String? = nil
    dynamic var coverImageURL:String? = nil
    dynamic var sharingTextWatching:String = "I'm watching [item]"
    dynamic var sharingTextWatched:String = "I just watched [item]"
    dynamic var isCurrentKrangUser:Bool = false
    
    override static func primaryKey() -> String? {
        return "username"
    }
    
    public class func getCurrentUser() -> KrangUser {
        let realm = try! Realm()
        let currentUser = realm.objects(KrangUser.self).filter("isCurrentKrangUser = true")
        if currentUser.count > 0 {
            return currentUser[0]
        }
        return KrangUser()
    }
    
    class func setCurrentUser(_ user: KrangUser?) {
        let realm = try! Realm()
        let turnTheseOff = realm.objects(KrangUser.self).filter("isCurrentKrangUser = true")
        for goodbye in turnTheseOff {
            if let user = user {
                if user.username == goodbye.username {
                    continue
                }
            }
            goodbye.isCurrentKrangUser = false
        }
        
        user?.isCurrentKrangUser = true
    }
    
    public class func from(json:JSON) -> KrangUser {
        guard let username = json["user"]["username"].string else {
            return KrangUser()
        }
        
        let user:KrangUser = {
            if let existingUser = RealmManager.shared.user(withUsername: username) {
                return existingUser
            } else {
                let newUser = KrangUser()
                newUser.username = username
                newUser.saveToDatabaseOutsideWriteTransaction()
                
                return newUser
            }
        }()
        
        user.update(withJSON: json)
        
        return user
    }
    
    func update(withJSON json:JSON) {
        self.name = json["user"]["name"].string
        self.slug = json["user"]["ids"]["slug"].string ?? ""
        self.vip = json["user"]["vip"].bool ?? false
        self.about = json["user"]["about"].string
        self.location = json["user"]["location"].string
        self.gender = json["user"]["gender"].string ?? "male"
        self.avatarImageURL = json["user"]["images"]["avatar"]["full"].string
        self.coverImageURL = json["account"]["cover_image"].string
        self.sharingTextWatching = json["sharing_text"]["watching"].string ?? "I'm watching [item]"
        self.sharingTextWatched = json["sharing_text"]["watching"].string ?? "I just watched [item]"        
    }
}
