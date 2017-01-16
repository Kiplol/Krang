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
    
    //MARK:- ivars
    @IBOutlet weak var labelTitle: MarqueeLabel!
    @IBOutlet weak var imageBackground: UIImageView!
    @IBOutlet weak var imagePoster: UIImageView!
    @IBOutlet weak var buttonIMDB: UIButton!
    @IBOutlet weak var buttonTMDB: UIButton!
    @IBOutlet weak var stackViewForButtons: UIStackView!
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
        
        let szURL = "krang://externalurl/\(tmdbURL.absoluteString)"
        self.extensionContext?.open(URL(string: szURL)!, completionHandler: nil)
    }
    
    @IBAction func imdbTapped(_ sender: Any) {
        guard let watchable = self.getCurrentWatchable() else {
            return
        }
        
        guard let imdbURL = watchable.urlForIMDB else {
            return
        }
        
        let szURL = "krang://externalurl/\(imdbURL.absoluteString)"
        self.extensionContext?.open(URL(string: szURL)!, completionHandler: nil)
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
            self.stackViewForButtons.removeArrangedSubview(self.buttonIMDB)
            self.stackViewForButtons.removeArrangedSubview(self.buttonTMDB)
            return
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
    
    //MARK:- NCWidgetProviding
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        
        let afterGettingTMDBConfiguartion = {
            TraktHelper.shared.getCheckedInMovieOrEpisode { (error, movie, episode) in
                self.movieID = nil
                self.episodeID = nil
                guard error == nil else {
                    completionHandler(NCUpdateResult.failed)
                    return
                }
                
                var backgroundImageURL:URL? = nil
                var posterImageURL:URL? = nil
                var watchable:KrangWatchable? = nil
                if let movie = movie {
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
                    self.episodeID = episode.traktID
                    watchable = episode
                    self.labelTitle.text = episode.titleDisplayString
                    if let stillThumbnailURL = episode.stillThumbnailImageURL {
                        backgroundImageURL = URL(string: stillThumbnailURL)
                    }
                    if let posterThumbnailURL = episode.posterThumbnailImageURL {
                       posterImageURL = URL(string: posterThumbnailURL)
                    }
                } else {
                    self.labelTitle.text = "Not Currently Watching Anything"
                    self.imageBackground.image = nil
                    self.updateButtonsFor(watchable: nil)
                    completionHandler(.noData)
                    return
                }
                
                self.updateButtonsFor(watchable: watchable)
                
                //Images
                let group = DispatchGroup()
                
                group.enter()
                group.enter()
                self.imageBackground.kf.setImage(with: backgroundImageURL, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
                    group.leave()
                })
                self.imagePoster.kf.setImage(with: posterImageURL, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
                    group.leave()
                })
                
                group.notify(queue: DispatchQueue.main, execute: { 
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
