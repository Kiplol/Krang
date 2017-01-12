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
    
    var traktID:Int? = nil

    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        TraktHelper.shared.getCheckedInMovie { [unowned self] (error, movie) in
            self.traktID = movie?.traktID
            self.updateViews(withMovie: movie)
        }
    }
    
    //MARK:- User Interaction
    
    @IBAction func imdbTapped(_ sender: Any) {
        guard let traktID = self.traktID else {
            return
        }
        
        guard let movie = KrangMovie.with(traktID: traktID) else {
            return
        }
        
        guard let imdbID = movie.imdbID else {
            return
        }
        
        let szURL = String(format: Constants.imdbURLFormat, imdbID)
        guard let url = URL(string: szURL) else {
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    //MARK:-
    func updateViews(withMovie movie:KrangMovie?) {
        self.imagePosterBackground.setPoster(fromMovie: movie)
        if let movie = movie {
        
        } else {
            
        }
    }

    // MARK: - Navigation
    @IBAction func unwindToPlayback(_ sender:UIStoryboardSegue) {
        
    }

}
