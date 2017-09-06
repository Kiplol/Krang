//
//  PlaybackViewController.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/9/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit

class PlaybackViewController: KrangViewController {
    
    //MARK:- ivars
    @IBOutlet weak var imagePosterBackground: UIImageView! {
        didSet {
            self.imagePosterBackground.heroModifiers = [.zPosition(1.0), .translate(x: 0.0, y: 200.0, z: 0.0), .fade]
        }
    }
    @IBOutlet weak var imageInfoBackground: UIImageView!
    @IBOutlet weak var avatar: KrangAvatarView! {
        didSet {
            self.avatar.heroModifiers = [.zPosition(20.0)]
        }
    }
    @IBOutlet weak var labelNowWatching: UILabel! {
        didSet {
            self.labelNowWatching.heroModifiers = [.zPosition(5.0), .fade]
        }
    }
    @IBOutlet weak var labelDisplayName: UILabel! {
        didSet {
            self.labelDisplayName.heroModifiers = [.zPosition(6.0), .fade]
        }
    }
    @IBOutlet weak var infoContainer: UIView! {
        didSet {
            self.infoContainer.heroModifiers = [.zPosition(4.0), .translate(x: 0.0, y: 120.0, z: 0.0)]
        }
    }
    @IBOutlet weak var progressView: KrangProgressView!
    @IBOutlet weak var shadowTop: UIImageView! {
        didSet {
            self.shadowTop.image = UIImage(gradientColors: [UIColor(white: 0.0, alpha: 0.7) , UIColor.clear])
            self.shadowTop.heroModifiers = [.zPosition(19.0), .fade, .translate(x: 0.0, y: -80.0, z: 0.0)]
        }
    }
    @IBOutlet weak var stackViewForButtons: UIStackView!
    @IBOutlet weak var buttonIMDB: UIButton!
    @IBOutlet weak var buttonTMDB: UIButton!
    @IBOutlet weak var buttonTrakt: UIButton!
    
    var traktMovieID:Int? = nil
    var traktEpisodeID:Int? = nil
    var watchable: KrangWatchable? = nil

    //MARK:- Initializers
    class func instantiatedFromStoryboard() -> PlaybackViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: "playback") as! PlaybackViewController
    }
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.stackViewForButtons.removeArrangedSubview(self.buttonIMDB)
        self.stackViewForButtons.removeArrangedSubview(self.buttonTMDB)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.labelNowWatching.font = UIFont(name: "Exo-Black", size: self.labelNowWatching.font.pointSize)
        self.refreshCheckin { 
            //Completion
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.progressView.stop()
    }
    
    //MARK:- App Lifecycle
    override func willEnterForeground(_ notif: Notification) {
        super.willEnterForeground(notif)
        self.refreshCheckin(nil)
    }
    
    override func didEnterBackground(_ notif: Notification) {
        super.didEnterBackground(notif)
        self.progressView.stop()
    }
    
    //MARK:- User Interaction
    @IBAction func imdbTapped(_ sender: Any) {
        var watchable:KrangWatchable? = nil
        if let episodeID = self.traktEpisodeID, let episode = KrangEpisode.with(traktID: episodeID) {
            watchable = episode
        } else if let movieID = self.traktMovieID, let movie = KrangMovie.with(traktID: movieID) {
            watchable = movie
        }
        
        guard let url = watchable?.urlForIMDB else {
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func tmdbTapped(_ sender: Any) {
        var watchable:KrangWatchable? = nil
        if let episodeID = self.traktEpisodeID, let episode = KrangEpisode.with(traktID: episodeID) {
            watchable = episode
        } else if let movieID = self.traktMovieID, let movie = KrangMovie.with(traktID: movieID) {
            watchable = movie
        }
        
        guard let url = watchable?.urlForTMDB else {
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
    //MARK:-
    func updateViews(withWatchable watchable:KrangWatchable?) {
        self.stackViewForButtons.removeArrangedSubview(self.buttonIMDB)
        self.stackViewForButtons.removeArrangedSubview(self.buttonTMDB)
        self.stackViewForButtons.removeArrangedSubview(self.buttonTrakt)
        self.buttonIMDB.isHidden = true
        self.buttonTMDB.isHidden = true
        self.buttonTrakt.isHidden = true
        if let watchable = watchable {
            self.imagePosterBackground.setPoster(fromWatchable: watchable)
            self.labelDisplayName.text = watchable.titleDisplayString
            self.labelNowWatching.isHidden = false
            if watchable.urlForTrakt != nil {
                self.stackViewForButtons.addArrangedSubview(self.buttonTrakt)
                self.buttonTrakt.isHidden = false
            }
            if watchable.urlForIMDB != nil {
                self.stackViewForButtons.addArrangedSubview(self.buttonIMDB)
                self.buttonIMDB.isHidden = false
            }
            if watchable.urlForTMDB != nil {
                self.stackViewForButtons.addArrangedSubview(self.buttonTMDB)
                self.buttonTMDB.isHidden = false
            }
        } else {
            self.imagePosterBackground.setPoster(fromMovie: nil)
            self.labelDisplayName.text = nil
            self.labelNowWatching.isHidden = true
            
        }
    }
    
    func updateProgressView(withCheckin checkin: KrangCheckin?) {
        guard let checkin = checkin else {
            self.progressView.stop()
            self.progressView.reset()
            self.progressView.isHidden = true
            return
        }
        
        self.progressView.isHidden = false
        self.progressView.startDate = checkin.dateStarted
        self.progressView.endDate = checkin.dateExpires
        self.progressView.start()
    }
    
    func refreshCheckin(_ completion:(() -> ())?) {
        TraktHelper.shared.getCheckedInMovieOrEpisode { (error, movie, episode) in
            var watchable:KrangWatchable? = nil
            if let movie = movie {
                self.traktMovieID = movie.traktID
                self.traktEpisodeID = nil
                watchable = movie
            } else if let episode = episode {
                self.traktEpisodeID = episode.traktID
                self.traktMovieID = nil
                watchable = episode
            }
            self.watchable = watchable
            
            if let coverImageURL = watchable?.fanartImageURL {
                KrangUser.getCurrentUser().makeChanges {
                    KrangUser.getCurrentUser().coverImageURL = coverImageURL.absoluteString
                }
            }
            
            self.updateViews(withWatchable: watchable)
            self.updateProgressView(withCheckin: watchable?.checkin)
            completion?()
        }
    }

    // MARK: - Navigation
    @IBAction func unwindToPlayback(_ sender:UIStoryboardSegue) {
        
    }

}
