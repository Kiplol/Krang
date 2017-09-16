//
//  SeasonCollectionViewCell.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 9/15/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit

class SeasonCollectionViewCell: UICollectionViewCell, SelfSizingCell {

    static let aspectRatio: CGFloat = 19.0 / 27.0
    
    //MARK:- IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    
    //MARK:-
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func update(withSeason season: KrangSeason) {
        self.labelTitle.text = season.title
        self.imageView.kf.setImage(with: URL.from(string: season.posterImageURL))
        //@TODO
    }
    
    //MARK:- SelfSizingCell
    static func size(forCollectionView collectionView: UICollectionView, withData data: Any?) -> CGSize {
        //@TODO: Content and section inset
        let collectionViewWidth = collectionView.bounds.size.width
        let cellWidth = collectionViewWidth / 2.0
        let cellHeight = cellWidth / SeasonCollectionViewCell.aspectRatio
        return CGSize(width: cellWidth, height: cellHeight)
    }

}
