//
//  KrangWatchablePreviewView.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 10/10/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import Kingfisher
import UIKit
import RealmSwift

class KrangWatchablePreviewView: UIView {

    @IBOutlet weak var posterClippingView: UIView!
    @IBOutlet weak var imageViewPoster: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDetail: UILabel!
    @IBOutlet weak var textViewOverview: UITextView! {
        didSet {
            self.textViewOverview.textContainerInset = .zero
        }
    }
    @IBOutlet weak var stackViewLabels: UIStackView!
    var notificationToken: NotificationToken? = nil
    
    deinit {
        self.notificationToken?.invalidate()
        self.notificationToken = nil
    }

    func setWatchable(_ watchable: KrangWatchable?) {
        self.notificationToken?.invalidate()
        self.notificationToken = nil
        updateUI(withWatchable: watchable)
        if let realmObject = watchable as? Object {
            self.notificationToken = realmObject.observe({ [unowned self] (change) in
                switch change {
                case .change(_, _):
                    self.updateUI(withWatchable: watchable)
                default:
                    break
                }
            })
        }

        if let movie = watchable as? KrangMovie {
            TraktHelper.shared.getExtendedInfo(forMovie: movie, completion: nil)
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
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.15 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            self.textViewOverview.setContentOffset(CGPoint.zero, animated: true)
            if self.textViewOverview.contentSize.height > self.textViewOverview.bounds.size.height {
                self.textViewOverview.flashScrollIndicators()
            }
        })
        
        if let szPosterURL = watchable.posterImageURL, let posterURL = URL(string: szPosterURL) {
            self.imageViewPoster.kf.setImage(with: (posterURL as? ImageDataProvider), placeholder: #imageLiteral(resourceName: "poster_placeholder_dark"), options: nil, progressBlock: nil, completionHandler: nil)
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
        self.textViewOverview.setContentOffset(CGPoint.zero, animated: true)
    }
}
