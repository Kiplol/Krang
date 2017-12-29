//
//  KrangAvatarView.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/10/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit

class KrangAvatarView: UIView {

    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.clipsToBounds = true
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.setAvatar(fromURL: KrangUser.getCurrentUser().avatarImageURL)
        self.imageView.clipsToBounds = true
        self.addSubview(self.imageView)
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        self.imageView.setAvatar(fromURL: KrangUser.getCurrentUser().avatarImageURL)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let minDimension = min(self.bounds.size.width, self.bounds.size.height)
        self.layer.cornerRadius = minDimension * 0.5
        
        self.imageView.frame = self.bounds
        self.imageView.frame.size.width -= max(minDimension * 0.05, 2.0)
        self.imageView.frame.size.height -= max(minDimension * 0.05, 2.0)
        self.imageView.center = CGPoint(x: self.bounds.size.width * 0.5, y: self.bounds.size.height * 0.5)
        self.imageView.layer.cornerRadius = min(self.imageView.bounds.size.width, self.imageView.bounds.size.height) * 0.5
    }

}
