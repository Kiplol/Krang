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
    @IBOutlet weak var shadowTop: UIImageView! {
        didSet {
            self.shadowTop.image = UIImage(gradientColors: [UIColor(white: 0.0, alpha: 0.7) , UIColor.clear])
            self.shadowTop.heroModifiers = [.zPosition(19.0), .fade]
        }
    }
    
    var traktMovieID:Int? = nil
    var traktEpisodeID:Int? = nil

    //MARK:- Initializers
    class func instantiatedFromStoryboard() -> PlaybackViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: "playback") as! PlaybackViewController
    }
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.labelNowWatching.font = UIFont(name: "Exo-Black", size: self.labelNowWatching.font.pointSize)
        self.refreshCheckin { 
            //Completion
        }
    }
    
    //MARK:- App Lifecycle
    override func willEnterForeground(_ notif: Notification) {
        super.willEnterForeground(notif)
        self.refreshCheckin(nil)
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
    
    //MARK:-
    func updateViews(withMovie movie:KrangMovie?, orEpisode episode:KrangEpisode?) {
        if let movie = movie {
            self.imagePosterBackground.setPoster(fromMovie: movie)
            self.labelDisplayName.text = movie.titleDisplayString
            self.labelNowWatching.isHidden = false
        } else if let episode = episode {
            self.imagePosterBackground.setPoster(fromEpisode: episode)
            self.labelDisplayName.text = episode.titleDisplayString
            self.labelNowWatching.isHidden = false
        } else {
            self.imagePosterBackground.setPoster(fromMovie: nil)
            self.labelDisplayName.text = nil
            self.labelNowWatching.isHidden = true
        }
    }
    
    func refreshCheckin(_ completion:(() -> ())?) {
        TraktHelper.shared.getCheckedInMovieOrEpisode { [unowned self] (error, movie, episode) in
            if let movie = movie {
                self.traktMovieID = movie.traktID
                self.traktEpisodeID = nil
            } else if let episode = episode {
                self.traktEpisodeID = episode.traktID
                self.traktMovieID = nil
            }
            
            self.updateViews(withMovie: movie, orEpisode: episode)
            completion?()
        }
    }

    // MARK: - Navigation
    @IBAction func unwindToPlayback(_ sender:UIStoryboardSegue) {
        
    }

}
