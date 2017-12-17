//
//  KrangDrawerViewController.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 12/16/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit

class KrangDrawerViewController: UIViewController {

    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var playbackContainer: UIView!
    @IBOutlet weak var constraintTopOfPlayback: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let playbackTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(KrangDrawerViewController.playbackTapped(_:)))
        self.playbackContainer.addGestureRecognizer(playbackTapGestureRecognizer)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.mainContainer.layoutIfNeeded()
        self.playbackContainer.layoutIfNeeded()
    }

    // MARK: - Drawer Opening / Closing

    @objc func playbackTapped(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.6, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
            self.constraintTopOfPlayback.constant = -self.view.bounds.size.height
            self.view.layoutIfNeeded()
            self.mainContainer.layoutIfNeeded()
            self.playbackContainer.layoutIfNeeded()
        }) { (finished) in
            
        }
    }
}
