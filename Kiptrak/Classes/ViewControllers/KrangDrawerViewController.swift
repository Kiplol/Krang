//
//  KrangDrawerViewController.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 12/16/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit

class KrangDrawerViewController: UIViewController {
    
    enum State {
        case hidden
        case collapsed
        case open
    }

    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var playbackContainer: UIView!
    @IBOutlet weak var constraintTopOfPlayback: NSLayoutConstraint!
    var state = State.hidden
    
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
        self.setDrawerState(.open)
    }
    
    @objc func playbackSwipedToHide(_ sender: UISwipeGestureRecognizer) {
        self.setDrawerState(.collapsed)
    }
    
    func setDrawerState(_ state: KrangDrawerViewController.State, animated: Bool = true) {
        guard self.state != state else {
            return
        }
        
        self.state = state
        let animation = {
            switch state {
            case .open:
                self.constraintTopOfPlayback.constant = self.view.bounds.size.height - 30.0 - KrangUtils.safeAreaInsets.top
                self.playbackContainer.cornerRadius = 10.0
            case .collapsed:
                self.constraintTopOfPlayback.constant = 100.0
                self.playbackContainer.cornerRadius = 0.0
            case .hidden:
                self.constraintTopOfPlayback.constant = 0.0
                self.playbackContainer.cornerRadius = 0.0
            }
            
            self.playbackContainer.superview?.cornerRadius = self.playbackContainer.cornerRadius
            self.view.layoutIfNeeded()
            self.mainContainer.layoutIfNeeded()
            self.playbackContainer.layoutIfNeeded()
        }
        
        let completion = {
            
        }
        
        if animated {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.4, options: [.beginFromCurrentState, .allowUserInteraction], animations: animation) { (finished) in
            completion()
        }
        } else {
            animation()
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
