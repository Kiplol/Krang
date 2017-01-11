//
//  SettingsViewController.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/10/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit

class SettingsViewController: KrangViewController {

    @IBOutlet weak var imageCover: UIImageView! {
        didSet {
            self.imageCover.setCoverImage(fromURL: KrangUser.getCurrentUser().coverImageURL)
            self.imageCover.heroModifiers = [.translate(x: 0.0, y: -200.0, z: 0.0)]
        }
    }
    @IBOutlet weak var imageAvatar: KrangAvatarView! {
        didSet {
            self.imageAvatar.heroModifiers = [.arc(intensity: 0.3), .zPosition(10.0)]
        }
    }
    @IBOutlet weak var buttonClose: UIButton! {
        didSet {
            self.buttonClose.heroModifiers = [.zPosition(11.0), .translate(x: 0.0, y: -200.0, z: 0.0)]
        }
    }
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
