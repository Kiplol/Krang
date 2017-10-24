//
//  KrangDateUtils.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/16/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit

extension Date {
    
    static let utcDateFormatter: DateFormatter = {
       let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }()
    
    static func from(utcTimestamp timestamp:String) -> Date? {
        return Date.utcDateFormatter.date(from: timestamp)
    }
    
    func toUTCTimestamp() -> String {
        return Date.utcDateFormatter.string(from: self)
    }
    
}
