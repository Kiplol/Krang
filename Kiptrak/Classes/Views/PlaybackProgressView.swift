//
//  PlaybackProgressView.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 12/23/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit
import MarqueeLabel

class PlaybackProgressView: NibView {

    @IBOutlet weak var progressFillView: KrangProgressView!
    @IBOutlet weak var labelDisplayName: MarqueeLabel!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var imagePoster: UIImageView!
    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        if self.subviews.isEmpty {
//            self.addSubview(Bundle.main.loadNibNamed("PlaybackProgressView", owner: self, options: nil)![0] as! UIView)
//        }
//    }
    
    func layout(withWatchable watchable: KrangWatchable?) {
        guard let watchable = watchable else {
            self.labelDisplayName.text = nil
            self.imagePoster.image = nil
            return
        }
        
        self.labelDisplayName.text = watchable.titleDisplayString
        self.imagePoster.setPoster(fromWatchable: watchable)
        self.updateProgressView(withCheckin: watchable.checkin)
    }
    
    private func updateProgressView(withCheckin checkin: KrangCheckin?) {
        guard let checkin = checkin else {
            self.progressFillView.stop()
            self.progressFillView.reset()
            self.progressFillView.isHidden = true
            return
        }
        
        self.progressFillView.isHidden = false
        self.progressFillView.startDate = checkin.dateStarted
        self.progressFillView.endDate = checkin.dateExpires
        self.progressFillView.didFinishClosure = { [unowned self] progressView in
            self.updateProgressView(withCheckin: nil)
        }
        self.progressFillView.start()
    }
    
    func stopUpdatingProgress() {
        self.progressFillView.stop()
    }
}
