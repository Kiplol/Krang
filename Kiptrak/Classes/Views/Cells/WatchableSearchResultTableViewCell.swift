//
//  WatchableSearchResultTableViewCell.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 9/13/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit
import RealmSwift

class WatchableSearchResultTableViewCell: UITableViewCell {

    @IBOutlet weak var imageViewThumbnail: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubtitle: UILabel!
    
    //MARK:- ivars
    var realmChangeToken: NotificationToken? = nil
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.realmChangeToken?.stop()
    }
    
    func update(withSearchable searchable: KrangSearchable) {
        if let thumbnailURL = searchable.urlForSearchResultThumbnailImage {
            self.imageViewThumbnail.kf.setImage(with: thumbnailURL)
        } else {
            if let movie = searchable as? KrangMovie {
                let movieID = movie.traktID
                let query = try! Realm().objects(KrangMovie.self).filter("traktID == %d", movieID)
                self.realmChangeToken?.stop()
                self.realmChangeToken = query.addNotificationBlock() { change in
                    if query.count > 0 {
                        if let updatedThumbnailURL = query[0].urlForSearchResultThumbnailImage {
                            self.imageViewThumbnail.kf.setImage(with: updatedThumbnailURL)
                        }
                    }
                }
            }
        }
        self.labelTitle.text = searchable.titleForSearchResult
        self.labelSubtitle.text = searchable.subtitleForSearchResult
    }
    
}
