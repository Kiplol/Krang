//
//  KrangRealmUtils.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/9/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit
import RealmSwift

class KrangRealmUtils : NSObject {
    
    class func makeChanges(changes:@escaping () -> Void) {
        let realm = try! Realm()
        guard !realm.isInWriteTransaction else {
            changes()
            return
        }
        try! realm.write({
            changes()
        })
    }
    
}

class RealmString : Object {
    
    dynamic var value: String = ""
    
    override static func primaryKey() -> String? {
        return "value"
    }
    
    class func with(value: String) -> RealmString {
        let realm = try! Realm()
        let existingStrings = realm.objects(RealmString.self).filter("value = %@", value)
        if existingStrings.count > 0 {
            return existingStrings.first!
        }
        
        let newString = RealmString()
        newString.value = value
        return newString
    }
    
}

extension Object {
    
    func makeChanges(changes:@escaping () -> Void) {
        let realm = try! Realm()
        try! realm.write({
            changes()
        })
    }
    
    func saveToDatbase() {
        let realm = try! Realm()
        try! realm.write({
            realm.add(self)
        })
    }
    
    func saveToDatabaseOutsideWriteTransaction() {
        let realm = try! Realm()
        realm.add(self)
    }
    
}
