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
        try! realm.write({
            changes()
        })
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
