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
    var playbackIsShowing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupGestureRecognizers()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.mainContainer.layoutIfNeeded()
        self.playbackContainer.layoutIfNeeded()
    }

    // MARK: - Drawer Opening / Closing
    @objc func playbackTapped(_ sender: UITapGestureRecognizer) {
        self.showPlayback()
    }
    
    @objc func playbackSwipedToHide(_ sender: UISwipeGestureRecognizer) {
        self.hidePlayback()
    }
    
    func showPlayback(_ animated: Bool = true) {
        guard !self.playbackIsShowing else {
            return
        }
        
        let animation = {
            self.constraintTopOfPlayback.constant = self.view.bounds.size.height - 30.0
            self.view.layoutIfNeeded()
            self.mainContainer.layoutIfNeeded()
            self.playbackContainer.layoutIfNeeded()
        }
        
        let completion = {
            self.playbackIsShowing = true
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.4, options: [.beginFromCurrentState, .allowUserInteraction], animations: animation) { (finished) in
            completion()
        }
    }
    
    func hidePlayback(_ animated: Bool = true) {
        guard self.playbackIsShowing else {
            return
        }
        
        let animation = {
            self.constraintTopOfPlayback.constant = 100.0
            self.view.layoutIfNeeded()
            self.mainContainer.layoutIfNeeded()
            self.playbackContainer.layoutIfNeeded()
        }
        let completion = {
            self.playbackIsShowing = false
        }
        UIView.animate(withDuration: 0.6, delay: 0.0, options: [.beginFromCurrentState, .allowUserInteraction, .curveEaseOut], animations: animation) { (finished) in
            completion()
        }
    }
    
    //MARK: - Gesture Recognizers
    fileprivate func setupGestureRecognizers() {
        let playbackTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(KrangDrawerViewController.playbackTapped(_:)))
        self.playbackContainer.addGestureRecognizer(playbackTapGestureRecognizer)
        
        let swipeToShowGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(KrangDrawerViewController.playbackTapped(_:)))
        swipeToShowGestureRecognizer.direction = .up
        self.playbackContainer.addGestureRecognizer(swipeToShowGestureRecognizer)
        
        let swipeToHideGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(KrangDrawerViewController.playbackSwipedToHide(_:)))
        swipeToHideGestureRecognizer.direction = .down
        self.playbackContainer.addGestureRecognizer(swipeToHideGestureRecognizer)
    }
}
