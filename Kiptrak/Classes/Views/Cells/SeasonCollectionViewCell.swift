//
//  SeasonCollectionViewCell.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 9/15/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit
import Kingfisher
import RealmSwift

class SeasonCollectionViewCell: UICollectionViewCell, SelfSizingCell {

    static let aspectRatio: CGFloat = 19.0 / 27.0
    
    //MARK:- IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    var realmChangeToken: NotificationToken? = nil
    var retrieveImageTask: RetrieveImageTask? = nil
    
    //MARK:-
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.realmChangeToken?.stop()
        self.imageView.image = nil
        self.retrieveImageTask?.cancel()
        self.retrieveImageTask = nil
    }
    
    func update(withSeason season: KrangSeason) {
        self.labelTitle.text = season.title
        
        self.realmChangeToken?.stop()
        self.retrieveImageTask?.cancel()
        self.retrieveImageTask = nil
        
        if let posterImageURL = season.posterImageURL ?? season.show?.imagePosterURL {
            self.imageView.kf.setImage(with: URL(string: posterImageURL))
        } else {
            let query = try! Realm().objects(KrangSeason.self).filter("traktID == %d", season.traktID)
            self.realmChangeToken = query.addNotificationBlock({ change in
                if query.count > 0 {
                    if let updatedPosterImageURL = query[0].posterImageURL ?? query[0].show?.imagePosterURL {
                        self.imageView.kf.setImage(with: URL(string: updatedPosterImageURL))
                    }
                }
            })
        }
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
