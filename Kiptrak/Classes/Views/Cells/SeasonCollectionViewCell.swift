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
    private static let listenForRealmChanges = false
    
    //MARK:- IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageSeen: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    var realmChangeToken: NotificationToken? = nil
    var retrieveImageTask: DownloadTask? = nil
    
    //MARK:-
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.realmChangeToken?.invalidate()
        self.retrieveImageTask?.cancel()
        self.retrieveImageTask = nil
        self.imageSeen.isHidden = true
    }
    
    func update(withSeason season: KrangSeason) {
        self.labelTitle.text = season.title

        self.imageSeen.isHidden = !(UserPrefs.traktSync && season.hasBeenWatched()) //Must work on getting the entire show/season/episode data from the get-go.
        
        //Use image that's already in there as a placeholder
        if let posterImageURLString = season.posterImageURL, let posterImageURL = URL(string: posterImageURLString) {
            self.retrieveImageTask = self.imageView.kf.setImage(with: posterImageURL, placeholder: self.imageView.image, options: nil, progressBlock: { progress, max in
                //
            }, completionHandler: { result in
                switch result {
                case .failure(_):
                    if let url = season.show?.imagePosterURLs.first?.value {
                        self.retrieveImageTask = self.imageView.kf.setImage(with: URL(string: url))
                    }
                    
                default:
                    break
                }
            })
        } else if SeasonCollectionViewCell.listenForRealmChanges {
            let query = try! Realm().objects(KrangSeason.self).filter("traktID == %d", season.traktID)
            self.realmChangeToken = query.observe({ change in
                switch change {
                case .update(let results, deletions: _, insertions: _, modifications: _):
                    if let updatedPosterImageURL = results.first?.posterImageURL ?? query[0].show?.imagePosterURL {
                        self.retrieveImageTask = self.imageView.kf.setImage(with: (URL(string: updatedPosterImageURL) as? ImageDataProvider), placeholder: self.imageView.image, options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
                    }
                default:
                    break
                }

            })
        } else {
            if let showPosterImage = season.show?.imagePosterURL {
                self.retrieveImageTask = self.imageView.kf.setImage(with: URL(string: showPosterImage))
            } else {
                self.imageView.image = #imageLiteral(resourceName: "poster_placeholder_dark")
            }
        }
    }
    
    //MARK:- SelfSizingCell
    static func size(forCollectionView collectionView: UICollectionView, withData data: Any?) -> CGSize {
        //@TODO: Content and section inset
        let idealWidth: CGFloat = 160.0
        let collectionViewWidth = collectionView.bounds.size.width
        let numberOfColumns = floor(collectionViewWidth / idealWidth)
        let cellWidth = collectionViewWidth / numberOfColumns
        let cellHeight = cellWidth / SeasonCollectionViewCell.aspectRatio
        return CGSize(width: cellWidth, height: cellHeight)
    }

}
