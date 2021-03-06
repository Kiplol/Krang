//
//  TodayViewController.swift
//  Currently Watching Widget
//
//  Created by Elliott Kipper on 1/15/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit
import NotificationCenter
import MarqueeLabel

class TodayViewController: UIViewController, NCWidgetProviding {
    
    private static let openURLsInAppFirst = true
    //MARK:- ivars
    @IBOutlet weak var labelTitle: MarqueeLabel!
    @IBOutlet weak var imageBackground: UIImageView!
    @IBOutlet weak var imagePoster: UIImageView!
    @IBOutlet weak var buttonIMDB: UIButton!
    @IBOutlet weak var buttonTMDB: UIButton!
    @IBOutlet weak var buttonTrakt: UIButton!
    @IBOutlet weak var stackViewForButtons: UIStackView!
    
    @IBOutlet weak var contentViewNotWatching: UIView!
    @IBOutlet weak var contentViewWatching: UIView!
    @IBOutlet weak var contentViewLoading: UIView!
    @IBOutlet weak var contentViewLogin: UIView!
    @IBOutlet weak var spinnerInWatching: UIActivityIndicatorView!
    @IBOutlet weak var spinnerInLoading: UIActivityIndicatorView!
    @IBOutlet weak var progressView: KrangProgressView!
    
    var visibleContentView: UIView? {
        didSet {
            self.visibleContentView?.isHidden = false
            for contentView: UIView in [self.contentViewNotWatching, self.contentViewWatching, self.contentViewLoading, self.contentViewLogin] {
                guard let visibleOne = self.visibleContentView else {
                    contentView.isHidden = true
                    continue
                }
                contentView.isHidden = (contentView != visibleOne)
            }
        }
    }
    
    var episodeID:Int? = nil
    var movieID:Int? = nil
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let _ = RealmManager.shared
        KrangLogger.setup()
        
        //TODO: Appearance
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- User Interaction
    
    @IBAction func tmdbTapped(_ sender: Any) {
        guard let watchable = self.getCurrentWatchable() else {
            return
        }
        
        guard let tmdbURL = watchable.urlForTMDB else {
            return
        }
        
        if TodayViewController.openURLsInAppFirst {
            let szURL = "krang://externalurl/\(tmdbURL.absoluteString)"
            self.extensionContext?.open(URL(string: szURL)!, completionHandler: nil)
        } else {
            self.extensionContext?.open(tmdbURL, completionHandler: nil)
        }
    }
    
    @IBAction func imdbTapped(_ sender: Any) {
        guard let watchable = self.getCurrentWatchable() else {
            return
        }
        
        guard let imdbURL = watchable.urlForIMDB else {
            return
        }
        
        if TodayViewController.openURLsInAppFirst {
            let szURL = "krang://externalurl/\(imdbURL.absoluteString)"
            self.extensionContext?.open(URL(string: szURL)!, completionHandler: nil)
        } else {
            self.extensionContext?.open(imdbURL, completionHandler: nil)
        }
    }
    
    @IBAction func traktTapped(_ sender: Any) {
        guard let watchable = self.getCurrentWatchable() else {
            return
        }
        
        guard let traktURL = watchable.urlForTrakt else {
            return
        }
        
        if TodayViewController.openURLsInAppFirst {
            let szURL = "krang://externalurl/\(traktURL.absoluteString)"
            self.extensionContext?.open(URL(string: szURL)!, completionHandler: nil)
        } else {
            self.extensionContext?.open(traktURL, completionHandler: nil)
        }
    }
    
    //MARK:-
    func getCurrentWatchable() -> KrangWatchable? {
        if let episodeID = self.episodeID {
            return KrangEpisode.with(traktID: episodeID)
        } else if let movieID = self.movieID {
            return KrangMovie.with(traktID: movieID)
        }
        return nil
    }
    
    func updateButtonsFor(watchable:KrangWatchable?) {
        guard let watchable = watchable else {
            self.buttonTMDB.isHidden = true
            self.buttonIMDB.isHidden = true
            self.buttonTrakt.isHidden = true
            self.stackViewForButtons.removeArrangedSubview(self.buttonIMDB)
            self.stackViewForButtons.removeArrangedSubview(self.buttonTMDB)
            self.stackViewForButtons.removeArrangedSubview(self.buttonTrakt)
            self.stackViewForButtons.isHidden = true
            return
        }
        
        self.stackViewForButtons.isHidden = false
        
        //Trakt
        if let _ = watchable.urlForTrakt {
            if self.buttonTrakt.isHidden {
                self.buttonTrakt.isHidden = false
                self.stackViewForButtons.addArrangedSubview(self.buttonTrakt)
            }
        } else {
            self.buttonTrakt.isHidden = true
            self.stackViewForButtons.removeArrangedSubview(self.buttonTrakt)
        }
        
        //IMDB
        if let _ = watchable.urlForIMDB {
            if self.buttonIMDB.isHidden {
                self.buttonIMDB.isHidden = false
                self.stackViewForButtons.addArrangedSubview(self.buttonIMDB)
            }
        } else if !self.buttonIMDB.isHidden {
            self.buttonIMDB.isHidden = true
            self.stackViewForButtons.removeArrangedSubview(self.buttonIMDB)
        }
        
        //TMDB
        if let _ = watchable.urlForTMDB {
            if self.buttonTMDB.isHidden {
                self.buttonTMDB.isHidden = false
                self.stackViewForButtons.addArrangedSubview(self.buttonTMDB)
            }
        } else if !self.buttonTMDB.isHidden {
            self.buttonTMDB.isHidden = true
            self.stackViewForButtons.removeArrangedSubview(self.buttonTMDB)
        }
    }
    
    //MARK:- User Interaction
    @IBAction func loginTapped(_ sender: Any) {
        let szURL = "krang://traktlogin"
        self.extensionContext?.open(URL(string: szURL)!, completionHandler: nil)
    }
    
    @IBAction func posterTapped(_ sender: Any) {
        self.extensionContext?.open(URL(string: "krang://")!, completionHandler: nil)
    }
    
    //MARK:- NCWidgetProviding
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        
        //First things first: make sure we're logged in to Trakt.
        guard !KrangUser.getCurrentUser().username.isEmpty,
            TraktHelper.shared.credentialsAreValid() else {
            //Not logged in.
            self.visibleContentView = self.contentViewLogin
            completionHandler(.newData)
            return
        }
        
        //OK cool; we are.  Now let's see if the widget would already be showing something by the time this opens.
        if self.contentViewWatching.isHidden == false {
            //Yeah, it's already visible, so we'll just show a small spinner in here.
            self.spinnerInWatching.startAnimating()
        } else {
            //There isn't already a watchable displaying, so we'll show the full loading content view.
            self.visibleContentView = self.contentViewLoading
            self.spinnerInLoading.startAnimating()
        }
        
        self.progressView.stop()
        let afterGettingTMDBConfiguartion = {
            TraktHelper.shared.getCheckedInMovieOrEpisode { (error, movie, episode) in
                self.movieID = nil
                self.episodeID = nil
                
                guard error == nil, TMDBHelper.shared.gotConfiguration else {
                    self.spinnerInWatching.stopAnimating()
                    completionHandler(NCUpdateResult.failed)
                    return
                }
                
                var backgroundImageURL:URL? = nil
                var posterImageURL:URL? = nil
                var watchable:KrangWatchable? = nil
                if let movie = movie {
                    self.visibleContentView = self.contentViewWatching
                    self.spinnerInWatching.startAnimating()
                    self.movieID = movie.traktID
                    watchable = movie
                    self.labelTitle.text = movie.titleDisplayString
                    if let backdropThumbnailURL = movie.backdropThumbnailImageURL {
                        backgroundImageURL = URL(string: backdropThumbnailURL)
                    }
                    if let posterThumbnailURL = movie.posterThumbnailImageURL {
                        posterImageURL = URL(string: posterThumbnailURL)
                    }
                } else if let episode = episode {
                    self.visibleContentView = self.contentViewWatching
                    self.spinnerInWatching.startAnimating()
                    
                    self.episodeID = episode.traktID
                    watchable = episode
                    self.labelTitle.text = episode.titleDisplayString
                    backgroundImageURL = watchable?.fanartBlurrableImageURL
                    if let posterThumbnailURL = episode.posterThumbnailImageURL ?? episode.season?.posterImageURL ?? episode.show?.imagePosterURL {
                        posterImageURL = URL(string: posterThumbnailURL)
                    }
                } else {
                    self.visibleContentView = self.contentViewNotWatching
                    
                    self.progressView.reset()
                    self.labelTitle.text = nil
                    self.imageBackground.image = nil
                    self.updateButtonsFor(watchable: nil)
                    completionHandler(.noData)
                    return
                }
                
                self.updateButtonsFor(watchable: watchable)
                
                self.progressView.startDate = watchable?.checkin?.dateStarted
                self.progressView.endDate = watchable?.checkin?.dateExpires
                self.progressView.start()
                
                //Images
                let group = DispatchGroup()
                
                group.enter()
                group.enter()
                self.imageBackground.kf.setImage(with: backgroundImageURL, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
                    if let image = image {
                        self.imageBackground.image = image.kf.blurred(withRadius: 1.0).kf.tinted(with: UIColor.darkBackground.alpha(0.9))
                    }
                    group.leave()
                })
                self.imagePoster.kf.setImage(with: posterImageURL, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
                    group.leave()
                })
                
                group.notify(queue: DispatchQueue.main, execute: {
                    self.spinnerInWatching.stopAnimating()
                    self.spinnerInLoading.stopAnimating()
                    completionHandler(.newData)
                })
            }
        }
        
        if TMDBHelper.shared.gotConfiguration {
            afterGettingTMDBConfiguartion()
        } else {
            TMDBHelper.shared.getConfiguration(completion: { (error) in
                afterGettingTMDBConfiguartion()
            })
        }
    }
    
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return .zero
    }
    
}
