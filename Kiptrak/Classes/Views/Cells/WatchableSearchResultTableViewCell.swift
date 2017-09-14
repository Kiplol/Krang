//
//  WatchableSearchResultTableViewCell.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 9/13/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit

class WatchableSearchResultTableViewCell: UITableViewCell {

    @IBOutlet weak var imageViewThumbnail: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubtitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update(withSearchable searchable: KrangSearchable) {
        if let thumbnailURL = searchable.urlForSearchResultThumbnailImage {
            self.imageViewThumbnail.kf.setImage(with: thumbnailURL)
        }
        self.labelTitle.text = searchable.titleForSearchResult
        self.labelSubtitle.text = searchable.subtitleForSearchResult
    }
    
}
