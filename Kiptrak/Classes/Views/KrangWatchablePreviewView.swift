//
//  KrangWatchablePreviewView.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 10/10/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit
import RealmSwift

class KrangWatchablePreviewView: UIView {
    
    @IBOutlet weak var posterClippingView: UIView!
    @IBOutlet weak var imageViewPoster: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDetail: UILabel!
//    @IBOutlet weak var labelOverview: UILabel!
    @IBOutlet weak var textViewOverview: UITextView! {
        didSet {
            self.textViewOverview.textContainerInset = .zero
        }
    }
    @IBOutlet weak var stackViewLabels: UIStackView!
    
    var notificationToken: NotificationToken? = nil
    
    deinit {
        self.notificationToken?.stop()
        self.notificationToken = nil
    }
    
    func setWatchable(_ watchable: KrangWatchable?) {
        self.notificationToken?.stop()
        self.notificationToken = nil
        updateUI(withWatchable: watchable)
        if let realmObject = watchable as? Object {
            self.notificationToken = realmObject.addNotificationBlock({ [unowned self] (change) in
                switch change {
                case .change(_):
                    self.updateUI(withWatchable: watchable)
                default:
                    break
                }
            })
        }
    }
    
    fileprivate func updateUI(withWatchable watchable: KrangWatchable?) {
        guard let watchable = watchable else {
            self.labelTitle.text = nil
            self.labelDetail.text = nil
            self.textViewOverview.text = nil
            self.imageViewPoster.image = #imageLiteral(resourceName: "poster_placeholder_dark")
            return
        }
        
        self.labelTitle.text = watchable.title
        self.labelDetail.text = watchable.title
        self.textViewOverview.text = watchable.overview
        if let szPosterURL = watchable.posterImageURL, let posterURL = URL(string: szPosterURL) {
            self.imageViewPoster.kf.setImage(with: posterURL, placeholder: #imageLiteral(resourceName: "poster_placeholder_dark"), options: nil, progressBlock: nil, completionHandler: nil)
        } else {
            self.imageViewPoster.image = #imageLiteral(resourceName: "poster_placeholder_dark")
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        [self.labelTitle, self.labelDetail].forEach{ $0.textColor = UIColor.darkBackground }
        self.textViewOverview.textColor = self.labelTitle.textColor
        self.stackViewLabels.removeArrangedSubview(self.labelTitle)
        self.stackViewLabels.removeArrangedSubview(self.labelDetail)
    }
}
