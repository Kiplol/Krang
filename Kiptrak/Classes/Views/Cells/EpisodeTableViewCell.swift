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
    @IBOutlet weak var labelAirDate: UILabel!
    @IBOutlet weak var labelsStackView: UIStackView!
    @IBOutlet weak var imageSeen: UIImageView!
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
        self.labelTitle.text = "\(episode.episode). \(episode.title)"
        if let airDate = episode.airDate {
            let szAirDate = DateFormatter.localizedString(from: airDate, dateStyle: .medium, timeStyle: .none)
            self.labelAirDate.text = szAirDate
            if !self.labelsStackView.arrangedSubviews.contains(self.labelAirDate) {
                self.labelsStackView.insertArrangedSubview(self.labelAirDate, at: 1)
            }
        } else {
            if self.labelsStackView.arrangedSubviews.contains(self.labelAirDate) {
                self.labelsStackView.removeArrangedSubview(self.labelAirDate)
            }
        }
        
        let shouldCheckMark = episode.watchDate != nil && UserPrefs.traktSync
        self.imageSeen.isHidden = !shouldCheckMark
        
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
