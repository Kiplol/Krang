//
//  NowWatchingViewController.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 12/28/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit

class NowWatchingViewController: KrangViewController {
    
    fileprivate enum Mode {
        case collapsed
        case full
    }
    // MARK: - ivars
    var watchable: KrangWatchable?
    fileprivate var mode: Mode = .collapsed {
        didSet {
            self.layout(forMode: self.mode)
        }
    }

    // MARK: IBOutlets
    @IBOutlet weak var layoutFrameInfoTop: UIView!
    @IBOutlet weak var layoutFrameInfoBottom: UIView!
    @IBOutlet weak var layoutFramePosterLarge: UIView!
    @IBOutlet weak var layoutFramePosterSmallTop: UIView!
    @IBOutlet weak var layoutFrameNameAndButtonsTop: UIView!
    @IBOutlet weak var layoutFrameNameAndButtonsBottom: UIView!

    // MARK: Info Stack View Constraints
    @IBOutlet weak var constraintInfoStackViewBottomTop: NSLayoutConstraint!
    @IBOutlet weak var constraintInfoStackViewBottomTrailing: NSLayoutConstraint!
    @IBOutlet weak var constraintInfoStackViewBottomBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintInfoStackViewBottomLeading: NSLayoutConstraint!
    
    @IBOutlet weak var constraintInfoStackViewTopTrailing: NSLayoutConstraint!
    @IBOutlet weak var constraintInfoStackViewTopLeading: NSLayoutConstraint!
    @IBOutlet weak var constraintInfoStackViewTopBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintInfoStackViewTopTop: NSLayoutConstraint!
    
    // MARK: Image Poster Constraints
    @IBOutlet weak var constraintImagePosterCenterTrailing: NSLayoutConstraint!
    @IBOutlet weak var constraintImagePosterCenterLeading: NSLayoutConstraint!
    @IBOutlet weak var constraintImagePosterCenterTop: NSLayoutConstraint!
    @IBOutlet weak var constraintImagePosterCenterBottom: NSLayoutConstraint!
    
    @IBOutlet weak var constraintImagePosterTopLeading: NSLayoutConstraint!
    @IBOutlet weak var constraintImagePosterTopTop: NSLayoutConstraint!
    @IBOutlet weak var constraintImagePosterTopBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintImagePosterTopTrailing: NSLayoutConstraint!
    
    @IBOutlet weak var imagePosterContainer: UIView!
    @IBOutlet weak var imagePoster: UIImageView!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(NowWatchingViewController.didCheckInToAWatchable(_:)), name: Notification.Name.didCheckInToWatchable, object: nil)
    }
    
    // MARK: - Notifications
    @objc func didCheckInToAWatchable(_ notif: Notification) {
        self.watchable = (notif.object as? KrangWatchable)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

private extension NowWatchingViewController {
    // MARK: - Info Stack View Constraints
    private var infoStackViewConstraintsForTop: [NSLayoutConstraint] {
        return [self.constraintInfoStackViewTopTop, self.constraintInfoStackViewTopBottom, self.constraintInfoStackViewTopLeading, self.constraintInfoStackViewTopTrailing]
    }
    private var infoStackViewConstraintsForBottom: [NSLayoutConstraint] {
        return [self.constraintInfoStackViewBottomTop, self.constraintInfoStackViewBottomBottom, self.constraintInfoStackViewBottomLeading, self.constraintInfoStackViewBottomTrailing]
    }
    private var allInfoStackViewConstraints: [NSLayoutConstraint] {
        return [self.infoStackViewConstraintsForTop, self.infoStackViewConstraintsForBottom].flatMap { $0 }
    }
    
    // MARK: - Image Poster Constraints
    private var imagePosterConstraintsForTop: [NSLayoutConstraint] {
        return [self.constraintImagePosterTopTop, self.constraintImagePosterTopBottom, self.constraintImagePosterTopLeading, self.constraintImagePosterTopTrailing]
    }
    private var imagePosterConstraintForCenter: [NSLayoutConstraint] {
        return [self.constraintImagePosterCenterTop, self.constraintImagePosterCenterBottom, self.constraintImagePosterCenterLeading, self.constraintImagePosterCenterTrailing]
    }
    private var allImagePosterConstraints: [NSLayoutConstraint] {
        return [self.imagePosterConstraintsForTop, self.imagePosterConstraintForCenter].flatMap { $0 }
    }
    
    // MARK: -
    private var allModeConstraints: [NSLayoutConstraint] {
        return [self.allInfoStackViewConstraints, self.allImagePosterConstraints].flatMap { $0 }
    }
    
    func constraints(forMode mode: Mode) -> [NSLayoutConstraint] {
        switch mode {
        case .collapsed:
            return [self.infoStackViewConstraintsForTop, self.imagePosterConstraintsForTop].flatMap { $0 }
        case .full:
            return [self.infoStackViewConstraintsForBottom, self.imagePosterConstraintForCenter].flatMap { $0 }
        }
    }
    
    func layout(forMode mode: Mode) {
        self.allModeConstraints.forEach { $0.isActive = false}
        self.constraints(forMode: mode).forEach { $0.isActive = true }
    }
}

extension NowWatchingViewController: KrangDrawerViewControllerDelegate {
    func drawerViewController(_ drawerViewController: KrangDrawerViewController, willChangeStateTo state: KrangDrawerViewController.State) {
        switch state {
        case .open:
            self.mode = .full
        default:
            self.mode = .collapsed
        }
    }
    
    func drawerViewController(_ drawerViewController: KrangDrawerViewController, didChangeStateTo state: KrangDrawerViewController.State) {
        
    }
}
