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
    var retrieveImageTask: DownloadTask? = nil
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.realmChangeToken?.invalidate()
        self.imageViewThumbnail.image = #imageLiteral(resourceName: "poster_placeholder_dark")
        self.retrieveImageTask?.cancel()
        self.retrieveImageTask = nil
    }
    
    func update(withSearchable searchable: KrangSearchable) {
        if let thumbnailURL = searchable.urlForSearchResultThumbnailImage {
            self.retrieveImageTask = self.imageViewThumbnail.kf.setImage(with: (thumbnailURL as? ImageDataProvider), placeholder: #imageLiteral(resourceName: "poster_placeholder_dark"), options: nil, progressBlock: nil, completionHandler: nil)
            self.retrieveImageTask = self.imageViewThumbnail.kf.setImage(with: thumbnailURL)
        } else if TraktHelper.asyncImageLoadingOnSearch {
            if let movie = searchable as? KrangMovie {
                let movieID = movie.traktID
                let query = try! Realm().objects(KrangMovie.self).filter("traktID == %d && posterThumbnailImageURL != nil", movieID)
                self.realmChangeToken = query.observe() { change in
                    switch change {
                    case .update(let results, deletions: _, insertions: _, modifications: _):
                        if let updatedThumbnailURL = results.first?.urlForSearchResultThumbnailImage {
                            self.retrieveImageTask = self.imageViewThumbnail.kf.setImage(with: (updatedThumbnailURL as URL), placeholder: #imageLiteral(resourceName: "poster_placeholder_dark"), options: nil, progressBlock: nil, completionHandler: { result in
//                                print(results)
                            })
                        }
                        break
                    default:
                        break
                    }
                }
            } else if let show = searchable as? KrangShow {
                let showID = show.traktID
                let query = try! Realm().objects(KrangShow.self).filter("traktID == %d && imagePosterURL != nil", showID)
                self.realmChangeToken = query.observe() { [unowned self] change in
                    
                    switch change {
                    case .update(let results, deletions: _, insertions: _, modifications: _):
                        if let updatedThumbnail = results.first?.urlForSearchResultThumbnailImage {
                            self.retrieveImageTask = self.imageViewThumbnail.kf.setImage(with: updatedThumbnail, placeholder: #imageLiteral(resourceName: "poster_placeholder_dark"), options: nil, progressBlock: { (progress, size) in
//                                print("\((Double(progress) / Double(size)) * 100)%%")
                            }, completionHandler: { result in
//                                print(result)
                            })
                        }
                        break
                    default:
                        break
                    }
                }
            }
        }
        self.labelTitle.text = searchable.titleForSearchResult
        self.labelSubtitle.text = searchable.subtitleForSearchResult
    }
    
}
