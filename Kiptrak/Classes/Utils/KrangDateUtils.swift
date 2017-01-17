//
//  KrangDateUtils.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/16/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit

extension Date {
    
    static let utcDateFormmater: DateFormatter = {
       let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }()
    
    static func from(utcTimestamp timestamp:String) -> Date? {
        return Date.utcDateFormmater.date(from: timestamp)
    }
    
}
