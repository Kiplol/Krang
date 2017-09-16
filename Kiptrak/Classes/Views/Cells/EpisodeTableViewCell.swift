//
//  EpisodeTableViewCell.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 9/16/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit
import SwipeCellKit

class EpisodeTableViewCell: SwipeTableViewCell {

    //MARK:- IBOutlets
//    @IBOutlet weak var imageViewPreview: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    //MARK:- ivars
    
    //MARK:-
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update(withEpisode episode: KrangEpisode) {
        self.labelTitle.text = "\(episode.episode). \(episode.title)"
        self.labelDescription.text = episode.overview
//        if let szImageURL = episode.stillThumbnailImageURL {
//            self.imageViewPreview.kf.setImage(with: URL(string: szImageURL), placeholder: self.imageViewPreview.image, options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
//        } else {
//            self.imageViewPreview.image = nil
//        }
        self.layoutIfNeeded()
    }
    
}
