//
//  SelfSizingCell.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 9/15/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit

protocol SelfSizingCell: class {
    static func size(forCollectionView collectionView:UICollectionView, withData data: Any?) -> CGSize
}
