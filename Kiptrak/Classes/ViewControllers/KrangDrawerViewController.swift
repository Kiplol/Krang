//
//  KrangDrawerViewController.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 12/16/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit

protocol KrangDrawerViewControllerDelegate: class {
    func drawerViewController(_ drawerViewController: KrangDrawerViewController, willChangeStateTo state: KrangDrawerViewController.State)
    func drawerViewController(_ drawerViewController: KrangDrawerViewController, didChangeStateTo state: KrangDrawerViewController.State)
}

class KrangDrawerViewController: UIViewController {
    
    enum State {
        case hidden
        case collapsed
        case open
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var playbackContainer: UIView!
    @IBOutlet weak var constraintTopOfPlayback: NSLayoutConstraint!
    
    // MARK: - ivars
    var state = State.hidden
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(KrangDrawerViewController.didCheckInToAWatchable(_:)), name: Notification.Name.didCheckInToWatchable, object: nil)
        self.setupGestureRecognizers()
        for childVC in self.childViewControllers {
            (childVC as? UINavigationController)?.interactivePopGestureRecognizer?.delegate = self
        }
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
        
        self.notifyChildrenStateWillChange(to: state)
        self.state = state
        let animation = {
            switch state {
            case .open:
                self.constraintTopOfPlayback.constant = self.view.bounds.size.height - 40.0
                self.playbackContainer.cornerRadius = 10.0
            case .collapsed:
                self.constraintTopOfPlayback.constant = 120.0
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
            self.notifyChildrenStateDidChange(to: state)
        }
        
        if animated {
            UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.7, options: [.beginFromCurrentState, .allowUserInteraction], animations: animation) { (finished) in
                completion()
            }
//            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.allowUserInteraction, .beginFromCurrentState, .curveEaseInOut], animations: animation, completion: { (_) in
//                completion()
//            })
        } else {
            animation()
            completion()
        }
    }
    
    // MARK: - Delegation
    private func notifyChildrenStateWillChange(to state: KrangDrawerViewController.State) {
        self.childViewControllers.forEach {
            ($0 as? KrangDrawerViewControllerDelegate)?.drawerViewController(self, willChangeStateTo: state)
        }
    }
    
    private func notifyChildrenStateDidChange(to state: KrangDrawerViewController.State) {
        self.childViewControllers.forEach {
            ($0 as? KrangDrawerViewControllerDelegate)?.drawerViewController(self, didChangeStateTo: state)
        }
    }
    
    // MARK: - Notifications
    @objc func didCheckInToAWatchable(_ notif: Notification) {
        if (notif.object as? KrangWatchable) != nil {
            if self.state == .hidden {
                self.setDrawerState(.collapsed)
            }
        } else {
            if self.state != .hidden {
                self.setDrawerState(.hidden)
            }
        }
    }
    
    // MARK: - Gesture Recognizers
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

extension KrangDrawerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension UINavigationController: KrangDrawerViewControllerDelegate {
    func drawerViewController(_ drawerViewController: KrangDrawerViewController, willChangeStateTo state: KrangDrawerViewController.State) {
        self.viewControllers.forEach {
            ($0 as? KrangDrawerViewControllerDelegate)?.drawerViewController(drawerViewController, willChangeStateTo: state)
        }
    }
    
    func drawerViewController(_ drawerViewController: KrangDrawerViewController, didChangeStateTo state: KrangDrawerViewController.State) {
        self.viewControllers.forEach {
            ($0 as? KrangDrawerViewControllerDelegate)?.drawerViewController(drawerViewController, didChangeStateTo: state)
        }
    }
    
    
}
