//
//  KrangSearchable.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 9/14/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit

protocol KrangSearchable: class {
    
    var urlForSearchResultThumbnailImage: URL? { get }
    var titleForSearchResult: String? { get }
    var subtitleForSearchResult: String? { get }
    
}
