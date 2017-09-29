//
//  SettingsViewController.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/10/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit

class SettingsViewController: KrangViewController, UITableViewDataSource, UITableViewDelegate {

    //MARK:- IBoutlets
    @IBOutlet weak var imageCover: UIImageView! {
        didSet {
            self.imageCover.setCoverImage(fromURL: KrangUser.getCurrentUser().coverImageURL)
            self.imageCover.heroModifiers = [.translate(x: 0.0, y: -200.0, z: 0.0), .zPosition(0.0)]
        }
    }
    @IBOutlet weak var avatar: KrangAvatarView! {
        didSet {
            self.avatar.heroModifiers = [.arc(intensity: 0.5), .zPosition(10.0)]
        }
    }
    @IBOutlet weak var buttonClose: UIButton! {
        didSet {
            self.buttonClose.heroModifiers = [.zPosition(12.0), .translate(x: 0.0, y: -200.0, z: 0.0)]
        }
    }
    @IBOutlet weak var shadowTop: UIImageView! {
        didSet {
            self.shadowTop.image = UIImage(gradientColors: [UIColor(white: 0.0, alpha: 0.7) , UIColor.clear])
            self.shadowTop.heroModifiers = [.fade, .translate(x: 0.0, y: -80.0, z: 0.0)]
        }
    }
    @IBOutlet weak var labelName: UILabel! {
        didSet {
            self.labelName.heroModifiers = [.fade, .translate(x: 0.0, y: -50.0, z: 0.0)]
        }
    }
    @IBOutlet weak var footerView: UIView! {
        didSet {
            self.footerView.heroModifiers = [.fade, .translate(x: 0.0, y: 70.0, z: 0.0)]
        }
    }
    @IBOutlet weak var constraintBelowStackView: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- Ivars
    fileprivate var rows = [Row]()
    fileprivate class Row {
        
    }
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.populateViews()
        self.constraintBelowStackView.constant = (16.0 + (KrangUtils.Display.typeIsLike == .iphoneX ? 25.0 : 0.0))
    }
    
    //MARK:-
    private func populateViews() {
        self.labelName.text = KrangUser.getCurrentUser().name
//        self.labelVersion.text = "Krang \(KrangUtils.versionAndBuildNumberString)"
    }
    
    //MARK:- UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //@TODO
        return UITableViewCell()
    }
    //MARK:- UITableViewDelegate
}
