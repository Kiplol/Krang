//
//  WatchableSearchResultTableViewCell.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 9/13/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit
import RealmSwift
import Kingfisher
import SwipeCellKit

class WatchableSearchResultTableViewCell: SwipeTableViewCell {

    @IBOutlet weak var imageViewThumbnail: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubtitle: UILabel!
    
    //MARK:- ivars
    var realmChangeToken: NotificationToken? = nil
    var retrieveImageTask: RetrieveImageTask? = nil
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.realmChangeToken?.stop()
        self.imageViewThumbnail.image = #imageLiteral(resourceName: "poster_placeholder_dark")
        self.retrieveImageTask?.cancel()
        self.retrieveImageTask = nil
    }
    
    func update(withSearchable searchable: KrangSearchable) {
        self.realmChangeToken?.stop()
        self.imageViewThumbnail.image = #imageLiteral(resourceName: "poster_placeholder_dark")
        self.retrieveImageTask?.cancel()
        self.retrieveImageTask = nil
        if let thumbnailURL = searchable.urlForSearchResultThumbnailImage {
            self.retrieveImageTask = self.imageViewThumbnail.kf.setImage(with: thumbnailURL, placeholder: #imageLiteral(resourceName: "poster_placeholder_dark"), options: nil, progressBlock: nil, completionHandler: nil)
        } else if TraktHelper.asyncImageLoadingOnSearch {
            if let movie = searchable as? KrangMovie {
                let movieID = movie.traktID
                let query = try! Realm().objects(KrangMovie.self).filter("traktID == %d", movieID)
                self.realmChangeToken = query.addNotificationBlock() { change in
                    if query.count > 0 {
                        if let updatedThumbnailURL = query[0].urlForSearchResultThumbnailImage {
                            self.retrieveImageTask = self.imageViewThumbnail.kf.setImage(with: updatedThumbnailURL, placeholder: #imageLiteral(resourceName: "poster_placeholder_dark"), options: nil, progressBlock: nil, completionHandler: nil)
                        }
                    }
                }
            } else if let show = searchable as? KrangShow {
                let showID = show.traktID
                let query = try! Realm().objects(KrangShow.self).filter("traktID == %d", showID)
                self.realmChangeToken = query.addNotificationBlock() { [unowned self] change in
                    if query.count > 0 {
                        if let updatedThumnailURL = query[0].urlForSearchResultThumbnailImage {
                            self.retrieveImageTask = self.imageViewThumbnail.kf.setImage(with: updatedThumnailURL, placeholder: #imageLiteral(resourceName: "poster_placeholder_dark"), options: nil, progressBlock: nil, completionHandler: nil)
                        }
                    }
                }
            }
        }
        self.labelTitle.text = searchable.titleForSearchResult
        self.labelSubtitle.text = searchable.subtitleForSearchResult
    }
    
}
