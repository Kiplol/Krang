//
//  PlaybackViewController.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/9/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit

class PlaybackViewController: KrangViewController {
    
    @IBOutlet weak var imagePosterBackground: UIImageView! {
        didSet {
            self.imagePosterBackground.heroModifiers = [.zPosition(1.0), .translate(x: 0.0, y: 200.0, z: 0.0), .fade]
        }
    }
    
    class func instantiatedFromStoryboard() -> PlaybackViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: "playback") as! PlaybackViewController
    }
    
    @IBOutlet weak var labelDisplayName: UILabel!
    
    
    var traktMovieID:Int? = nil
    var traktEpisodeID:Int? = nil

    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshCheckin { 
            //Completion
        }
    }
    
    //MARK:- User Interaction
    @IBAction func imdbTapped(_ sender: Any) {
        guard let traktID = self.traktMovieID else {
            return
        }
        
        guard let movie = KrangMovie.with(traktID: traktID) else {
            return
        }
        
        guard let url = movie.urlForIMDB else {
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func tmdbTapped(_ sender: Any) {
        if let episodeID = self.traktEpisodeID {
            guard let episode = KrangEpisode.with(traktID: episodeID) else {
                return
            }
            
            guard let url = episode.urlForTMDB else {
                return
            }
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            
        }
    }
    
    //MARK:-
    func updateViews(withMovie movie:KrangMovie?, orEpisode episode:KrangEpisode?) {
        if let movie = movie {
            self.imagePosterBackground.setPoster(fromMovie: movie)
        } else if let episode = episode {
            self.imagePosterBackground.setPoster(fromEpisode: episode)
            self.labelDisplayName.text = episode.title
        } else {
            self.imagePosterBackground.setPoster(fromMovie: nil)
            self.labelDisplayName.text = nil
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
