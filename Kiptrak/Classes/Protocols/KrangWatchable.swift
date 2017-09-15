//
//  KrangWatchable.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/15/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit

protocol KrangWatchable: KrangLinkable {
    
    var traktID: Int { get }
    var imdbID: String? { get }
    var tmdbID: Int { get }
    var posterImageURL: String? { get }
    
    var titleDisplayString: String { get }
    var posterThumbnailURL: URL? { get }
    var checkin:KrangCheckin? { get }
    
    var fanartImageURL: URL? { get }
    var fanartBlurrableImageURL : URL? { get }
    
    var originalJSONString: String { get }
}
