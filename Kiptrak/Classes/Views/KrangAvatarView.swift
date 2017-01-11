//
//  KrangAvatarView.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/10/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit

class KrangAvatarView: UIImageView {

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        self.setAvatar(fromURL: KrangUser.getCurrentUser().avatarImageURL)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.clipsToBounds = true
        self.layer.cornerRadius = self.bounds.size.height * 0.5
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1.0
    }

}
