//
//  NowWatchingViewController.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 12/28/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import MarqueeLabel
import UIKit

class NowWatchingViewController: KrangViewController {
    
    fileprivate enum Mode {
        case collapsed
        case full
    }
    // MARK: - ivars
    var watchable: KrangWatchable? {
        didSet {
            self.layout(withWatchable: self.watchable)
        }
    }
    fileprivate var mode: Mode = .collapsed {
        didSet {
            self.layout(forMode: self.mode)
        }
    }

    // MARK: IBOutlets
    @IBOutlet weak var labelWatchableName: MarqueeLabel!
    @IBOutlet weak var imagePoster: UIImageView!
    @IBOutlet weak var imageBackground: UIImageView!
    @IBOutlet weak var buttonIMDb: UIButton!
    @IBOutlet weak var buttonTMDB: UIButton!
    @IBOutlet weak var buttonTrakt: UIButton!
    @IBOutlet weak var progressView: KrangProgressView!
    
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
    
    // MARK: Progress View Constrains
    @IBOutlet weak var constraintProgressViewBottomTop: NSLayoutConstraint!
    @IBOutlet weak var constraintProgressViewBottomBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintProgressViewTopTop: NSLayoutConstraint!
    @IBOutlet weak var constraintProgressViewTopHeight: NSLayoutConstraint!
    
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(NowWatchingViewController.didCheckInToAWatchable(_:)), name: Notification.Name.didCheckInToWatchable, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.layout(withWatchable: self.watchable)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.progressView.stop()
    }
    
    // MARK: - User Interaction
    @IBAction func imdbTapped(_ sender: Any) {
        guard let url = self.watchable?.urlForIMDB else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func tmdbTapped(_ sender: Any) {
        guard let url = self.watchable?.urlForTMDB else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func traktTapped(_ sender: Any) {
        guard let url = self.watchable?.urlForTrakt else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func cancelCheckInTapped(_ sender: Any) {
        let _ = KrangActionableFullScreenAlertView.show(withTitle: "Cancelling checkin", countdownDuration: 3.0, afterCountdownAction: { (alert) in
            TraktHelper.shared.cancelAllCheckins { (error) in
                KrangUtils.playFeedback(forResult: error)
                alert.dismiss(true)
            }
        }, buttonTitle: "Stay Checked In") { (alert, button) in
            alert.dismiss(true)
        }
    }
    
    // MARK: - Notifications
    @objc func didCheckInToAWatchable(_ notif: Notification) {
        self.watchable = (notif.object as? KrangWatchable)
    }
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
    
    // MARK: - Progress View Constraints
    private var progressViewConstraintsForTop: [NSLayoutConstraint] {
        return [self.constraintProgressViewTopTop, self.constraintProgressViewTopHeight]
    }
    private var progressViewConstraintsForBottom: [NSLayoutConstraint] {
        return [self.constraintProgressViewBottomTop, self.constraintProgressViewBottomBottom]
    }
    private var allProgressViewConstraints: [NSLayoutConstraint] {
        return [self.progressViewConstraintsForTop, self.progressViewConstraintsForBottom].flatMap { $0 }
    }
    // MARK: -
    private var allModeConstraints: [NSLayoutConstraint] {
        return [self.allInfoStackViewConstraints, self.allImagePosterConstraints, self.allProgressViewConstraints].flatMap { $0 }
    }
    
    func constraints(forMode mode: Mode) -> [NSLayoutConstraint] {
        switch mode {
        case .collapsed:
            return [self.infoStackViewConstraintsForTop, self.imagePosterConstraintsForTop, self.progressViewConstraintsForTop].flatMap { $0 }
        case .full:
            return [self.infoStackViewConstraintsForBottom, self.imagePosterConstraintForCenter, self.progressViewConstraintsForBottom].flatMap { $0 }
        }
    }
    
    func layout(forMode mode: Mode) {
        self.allModeConstraints.forEach { $0.isActive = false}
        self.constraints(forMode: mode).forEach { $0.isActive = true }
        switch mode {
        case .collapsed:
            self.imageBackground.alpha = 0.0
        default:
            self.imageBackground.alpha = 0.5
        }
    }
    
    // MARK: -
    func layout(withWatchable watchable: KrangWatchable?) {
        self.imagePoster.setPoster(fromWatchable: watchable)
        self.layoutLinkButons(forWatchable: watchable)
        self.layoutProgressView(forWatchable: watchable)
        guard let watchable = watchable else {
            self.labelWatchableName.text = nil
            self.imageBackground.image = nil
            return
        }
        
        self.labelWatchableName.text = watchable.titleDisplayString
        self.imageBackground.kf.setImage(with: watchable.posterThumbnailURL, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
            if let image = image {
                self.imageBackground.image = image.kf.blurred(withRadius: 4.0)
            }
        })
    }
    
    func layoutLinkButons(forWatchable watchable: KrangWatchable?) {
        let shouldHideIMDb = watchable?.urlForIMDB == nil
        let shouldHideTMDB = watchable?.urlForTMDB == nil
        let shouldHideTrakt = watchable?.urlForTrakt == nil
        let hideMap: [UIButton: Bool] = [self.buttonIMDb: shouldHideIMDb, self.buttonTMDB: shouldHideTMDB, self.buttonTrakt: shouldHideTrakt]
        hideMap.filter { $0.key.isHidden != $0.value }.forEach { $0.key.isHidden = $0.value }
    }
    
    func layoutProgressView(forWatchable watchable: KrangWatchable?) {
        guard let startDate = watchable?.checkin?.dateStarted,
            let endDate = watchable?.checkin?.dateExpires else {
                self.progressView.stop()
                self.progressView.reset()
                return
        }
        
        self.progressView.startDate = startDate
        self.progressView.endDate = endDate
        self.progressView.didFinishClosure = { _ in
            TraktHelper.shared.getCheckedInMovieOrEpisode { (error, movie, episode) in
                NotificationCenter.default.post(name: Notification.Name.didCheckInToWatchable, object: (movie ?? episode), userInfo: nil)
            }
        }
        self.progressView.start()
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
