//
//  PlaybackProgressView.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 12/23/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit

class PlaybackProgressView: NibView {

    @IBOutlet weak var progressFill: UIView!
    @IBOutlet weak var labelDisplayName: UILabel!
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
    }
}
