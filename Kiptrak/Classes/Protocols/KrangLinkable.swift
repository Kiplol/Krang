//
//  KrangLinkable.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 9/15/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit

protocol KrangLinkable: class {
    var title: String { get }
    var urlForIMDB: URL? { get }
    var urlForTMDB: URL? { get }
    var urlForTrakt: URL? { get }
}
