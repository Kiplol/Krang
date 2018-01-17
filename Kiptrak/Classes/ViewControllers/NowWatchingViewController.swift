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
    private var piecesOfTrivia: [String]?

    // MARK: IBOutlets
    @IBOutlet weak var labelWatchableName: MarqueeLabel!
    @IBOutlet weak var imagePoster: UIImageView!
    @IBOutlet weak var imageBackground: UIImageView!
    @IBOutlet weak var buttonIMDb: UIButton!
    @IBOutlet weak var buttonTMDB: UIButton!
    @IBOutlet weak var buttonTrakt: UIButton!
    @IBOutlet weak var progressView: KrangProgressView!
    @IBOutlet weak var detailsBottomContainerView: UIView!
    @IBOutlet weak var triviaContainerView: UIView!
    @IBOutlet weak var textViewTrivia: UITextView!
    @IBOutlet weak var constraintTextViewTriviaHeight: NSLayoutConstraint!
    
    // MARK: Info Stack View Constraints
    @IBOutlet weak var constraintInfoStackViewBottomBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintInfoStackViewBottomLeading: NSLayoutConstraint!
    
    @IBOutlet weak var constraintInfoStackViewTopBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintInfoStackViewTopTop: NSLayoutConstraint!
    
    // MARK: Image Poster Constraints
    @IBOutlet weak var constraintImagePosterCenterTrailing: NSLayoutConstraint!
    @IBOutlet weak var constraintImagePosterCenterLeading: NSLayoutConstraint!
    @IBOutlet weak var constraintImagePosterCenterTop: NSLayoutConstraint!
    @IBOutlet weak var constraintImagePosterCenterBottom: NSLayoutConstraint!
    
    @IBOutlet weak var constraintImagePosterTopLeading: NSLayoutConstraint!
    @IBOutlet weak var constraintImagePosterTopTop: NSLayoutConstraint!
    @IBOutlet weak var constraintImagePosterTopWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintImagePosterTopTrailing: NSLayoutConstraint!
    @IBOutlet weak var constraintImagePosterTopAspectRatio: NSLayoutConstraint!
    
    // MARK: Image Background Constraints
    @IBOutlet weak var constraintImageBackgroundTopBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintImageBackgroundBottomBottom: NSLayoutConstraint!
    
    // MARK: Progress View Constrains
    @IBOutlet weak var constraintProgressViewBottomTop: NSLayoutConstraint!
    @IBOutlet weak var constraintProgressViewTopTop: NSLayoutConstraint!
    
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
    
    @IBAction func toggleTriviaTapped(_ sender: Any) {
        self.triviaContainerView.isHidden = !self.triviaContainerView.isHidden
    }
    
    @IBAction func previousTapped(_ sender: Any) {
        guard let piecesOfTrivia = self.piecesOfTrivia, let index = piecesOfTrivia.index(of: self.textViewTrivia.text)?.advanced(by: 0) else {
            return
        }
        
        let previousPiece = index == 0 ? piecesOfTrivia[piecesOfTrivia.count - 1] : piecesOfTrivia[index - 1]
        self.setText(asTrivia: previousPiece)
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        guard let piecesOfTrivia = self.piecesOfTrivia, let index = piecesOfTrivia.index(of: self.textViewTrivia.text)?.advanced(by: 0) else {
            return
        }
        
        let nextPiece = index == (piecesOfTrivia.count - 1) ? piecesOfTrivia[0] : piecesOfTrivia[index + 1]
        self.setText(asTrivia: nextPiece)
    }
    
    // MARK: - Trivia
    private func setText(asTrivia text: String?) {
        guard let text = text else {
            self.triviaContainerView.isHidden = true
            return
        }
        self.textViewTrivia.text = text
        self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: [], animations: {
            let maxHeight: CGFloat = 160.0
            self.constraintTextViewTriviaHeight.constant = min(self.textViewTrivia.contentSize.height, maxHeight)
            self.view.layoutIfNeeded()
            self.textViewTrivia.scrollRangeToVisible(NSRange(location:0, length:0))
            if self.constraintTextViewTriviaHeight.constant >= maxHeight {
                self.textViewTrivia.flashScrollIndicators()
            }
        }, completion: nil)
    }
    
    // MARK: - Notifications
    @objc func didCheckInToAWatchable(_ notif: Notification) {
        guard (notif.object as? KrangWatchable)?.checkin != nil else {
            TraktHelper.shared.getCheckedInMovieOrEpisode { (error, movie, episode) in
                self.watchable = movie ?? episode
            }
            return
        }
        self.watchable = (notif.object as? KrangWatchable)
    }
}

private extension NowWatchingViewController {
    // MARK: - Info Stack View Constraints
    private var infoStackViewConstraintsForTop: [NSLayoutConstraint] {
        return [self.constraintInfoStackViewTopTop, self.constraintInfoStackViewTopBottom]
    }
    private var infoStackViewConstraintsForBottom: [NSLayoutConstraint] {
        return [self.constraintInfoStackViewBottomBottom, self.constraintInfoStackViewBottomLeading]
    }
    private var allInfoStackViewConstraints: [NSLayoutConstraint] {
        return [self.infoStackViewConstraintsForTop, self.infoStackViewConstraintsForBottom].flatMap { $0 }
    }
    
    // MARK: - Image Poster Constraints
    private var imagePosterConstraintsForTop: [NSLayoutConstraint] {
        return [self.constraintImagePosterTopTop, self.constraintImagePosterTopWidth, self.constraintImagePosterTopLeading, self.constraintImagePosterTopTrailing, constraintImagePosterTopAspectRatio]
    }
    private var imagePosterConstraintForCenter: [NSLayoutConstraint] {
        return [self.constraintImagePosterCenterTop, self.constraintImagePosterCenterBottom, self.constraintImagePosterCenterLeading, self.constraintImagePosterCenterTrailing]
    }
    private var allImagePosterConstraints: [NSLayoutConstraint] {
        return [self.imagePosterConstraintsForTop, self.imagePosterConstraintForCenter].flatMap { $0 }
    }
    
    // MARK: - Image Background Constraints
    private var imageBackgroundConstraintsForTop: [NSLayoutConstraint] {
        return [self.constraintImageBackgroundTopBottom]
    }
    private var imageBackgroundConstraintsForBottom: [NSLayoutConstraint] {
        return [self.constraintImageBackgroundBottomBottom]
    }
    private var allImageBackgroundConstraints: [NSLayoutConstraint] {
        return [self.imageBackgroundConstraintsForTop, self.imageBackgroundConstraintsForBottom].flatMap { $0 }
    }
    
    // MARK: - Progress View Constraints
    private var progressViewConstraintsForTop: [NSLayoutConstraint] {
        return [self.constraintProgressViewTopTop]
    }
    private var progressViewConstraintsForBottom: [NSLayoutConstraint] {
        return [self.constraintProgressViewBottomTop]
    }
    private var allProgressViewConstraints: [NSLayoutConstraint] {
        return [self.progressViewConstraintsForTop, self.progressViewConstraintsForBottom].flatMap { $0 }
    }
    // MARK: -
    private var allModeConstraints: [NSLayoutConstraint] {
        return [self.allInfoStackViewConstraints, self.allImagePosterConstraints, self.allProgressViewConstraints, self.allImageBackgroundConstraints].flatMap { $0 }
    }
    
    func constraints(forMode mode: Mode) -> [NSLayoutConstraint] {
        switch mode {
        case .collapsed:
            return [self.infoStackViewConstraintsForTop, self.imagePosterConstraintsForTop, self.progressViewConstraintsForTop, self.imageBackgroundConstraintsForTop].flatMap { $0 }
        case .full:
            return [self.infoStackViewConstraintsForBottom, self.imagePosterConstraintForCenter, self.progressViewConstraintsForBottom, self.imageBackgroundConstraintsForBottom].flatMap { $0 }
        }
    }
    
    func layout(forMode mode: Mode) {
        self.allModeConstraints.forEach { $0.isActive = false}
        self.constraints(forMode: mode).forEach { $0.isActive = true }

        UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.7, options: [.beginFromCurrentState], animations: {
            switch mode {
            case .collapsed:
                self.imageBackground.alpha = 0.0
                self.detailsBottomContainerView.isHidden = true
                self.detailsBottomContainerView.alpha = 0.0
            default:
                self.imageBackground.alpha = 1.0
                self.detailsBottomContainerView.isHidden = self.piecesOfTrivia?.isEmpty ?? true
                self.detailsBottomContainerView.alpha = 1.0
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    // MARK: -
    func layout(withWatchable watchable: KrangWatchable?) {
        self.imagePoster.setPoster(fromWatchable: watchable)
        self.layoutLinkButons(forWatchable: watchable)
        self.layoutProgressView(forWatchable: watchable)
        guard let watchable = watchable else {
            self.labelWatchableName.text = nil
            self.imageBackground.image = nil
            self.setText(asTrivia: nil)
            return
        }
        
        self.detailsBottomContainerView.isHidden = true
        
        self.labelWatchableName.text = watchable.titleDisplayString
        let backgroundImageURL: String? = (watchable.fanartImageURL?.absoluteString ?? watchable.posterImageURL)
        backgroundImageURL.flatMap { URL(string: $0) }.map {
            self.imageBackground.kf.setImage(with: $0, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
                if let image = image {
                    self.imageBackground.image = image.kf.blurred(withRadius: 10.0)
                }
            }) } ?? { self.imageBackground.image = nil }()
        
        IMDBHelper.shared.getTrivia(forWatchable: watchable) { piecesOfTrivia in
            self.detailsBottomContainerView.isHidden = !piecesOfTrivia.isEmpty && self.mode != .full
            self.piecesOfTrivia = piecesOfTrivia
            self.setText(asTrivia: piecesOfTrivia.first)
            if !piecesOfTrivia.isEmpty {
                self.triviaContainerView.isHidden = false
            }
            self.view.layoutIfNeeded()
        }
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
