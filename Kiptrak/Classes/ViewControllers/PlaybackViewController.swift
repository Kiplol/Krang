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

    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        TraktHelper.shared.getCheckedInMovie { [unowned self] (error, movie) in
            self.updateViews(withMovie: movie)
        }
    }
    
    //MARK:-
    func updateViews(withMovie movie:KrangMovie?) {
        if let movie = movie {
            self.imagePosterBackground.setPoster(fromMovie: movie)
        } else {
            
        }
    }

    // MARK: - Navigation
    @IBAction func unwindToPlayback(_ sender:UIStoryboardSegue) {
        
    }

}
