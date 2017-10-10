//
//  KrangCheckin.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/16/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import Foundation
import RealmSwift

class KrangCheckin: Object {
    
    @objc dynamic var dateStarted:Date? = nil
    @objc dynamic var dateExpires:Date? = nil
    
}
