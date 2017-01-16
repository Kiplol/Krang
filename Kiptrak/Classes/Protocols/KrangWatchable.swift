//
//  KrangWatchable.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/15/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit

protocol KrangWatchable {
    var titleDisplayString: String { get }
    var posterThumbnailURL: URL? { get }
    var urlForIMDB: URL? { get }
    var urlForTMDB: URL? { get }
}
