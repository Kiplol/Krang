//
//  RealmManager.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/9/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit
import RealmSwift

class RealmManager: NSObject {

    static let shared = RealmManager()
    
    override init() {
        super.init()
        
        var config = Realm.Configuration.defaultConfiguration
        
        //Set default Realm path
        let directory: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.kip.krang")!
        let realmPath = directory.path + "db.realm"
        config.fileURL = URL(string: realmPath)!
        
        //Migrate if needed
        config.schemaVersion = 2
        config.migrationBlock = {migration, oldSchema in
            if oldSchema < 1 {
                
            }
        }

        Realm.Configuration.defaultConfiguration = config
        
        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        _ = try! Realm()
    }
    
    func user(withUsername username:String?) -> KrangUser? {
        guard let username = username else {
            return nil
        }
        
        let realm = try! Realm()
        let matchingUser = realm.object(ofType: KrangUser.self, forPrimaryKey: username)
        return matchingUser
        
    }
    
}
