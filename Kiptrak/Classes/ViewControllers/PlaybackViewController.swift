//
//  PlaybackViewController.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/9/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit

class PlaybackViewController: KrangViewController {
    
    @IBOutlet weak var imagePosterBackground: UIImageView!
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
        TraktHelper.shared.getCheckedInMovie { (error, movie) in
            //
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation
    @IBAction func unwindToPlayback(_ sender:UIStoryboardSegue) {
        
    }

}
