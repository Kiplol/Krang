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
    @IBOutlet weak var imageViewPreview: UIImageView!
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.labelTitle.text = nil
        self.labelDescription.text = nil
        self.imageViewPreview.image = #imageLiteral(resourceName: "episode_still_placeholder")
    }
    
    func update(withEpisode episode: KrangEpisode) {
        let titleText = "\(episode.episode). \(episode.title)"
        if let airDate = episode.airDate {
            let attributedTitleText = NSMutableAttributedString(string: titleText)
            let datePart = NSAttributedString(string: "\n"+DateFormatter.localizedString(from: airDate, dateStyle: .medium, timeStyle: .none), attributes: [NSFontAttributeName: UIFont(name: "Exo-Light-Italic", size: 10.0)])
            attributedTitleText.append(datePart)
            self.labelTitle.attributedText = attributedTitleText
        } else {
            self.labelTitle.text = titleText
        }
        
        self.labelDescription.text = episode.overview
        let szImageURL: String? = {
            if episode.stillImageURLs.count > 1 {
                return episode.stillImageURLs[1].value
            } else if !episode.stillImageURLs.isEmpty {
                return episode.stillImageURLs[0].value
            } else {
                return nil
            }
        }()
        if let szImageURL = szImageURL {
            self.imageViewPreview.kf.setImage(with: URL(string: szImageURL), placeholder: self.imageViewPreview.image, options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
        } else {
            self.imageViewPreview.image = #imageLiteral(resourceName: "episode_still_placeholder")
        }
        self.layoutIfNeeded()
    }
    
}
