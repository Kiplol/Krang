//
//  ViewController.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/8/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit
import OAuthSwift

class SplashViewController: KrangViewController {

    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        TMDBHelper.shared.getConfiguration { (error) in
            guard error == nil else {
                //TODO: Some shit
                return
            }
            if TraktHelper.shared.credentialsAreValid() {
                TraktHelper.shared.getMyProfile(completion: { error, user in
                    //Peeee
                    if user != nil && user!.username.characters.count > 0 {
                        KrangLogger.log.debug("User \(user!.username) is already logged in, so proceed to playback")
                        self.goToPlayback()
                    } else {
                        self.goToOnboarding()
                    }
                })
            } else {
                
            }
        }
    }
    
    //MARK:-
    private func goToPlayback() {
        let playbackVC = PlaybackViewController.instantiatedFromStoryboard()
        self.navigationController?.setViewControllers([playbackVC], animated: false)
    }
    
    private func goToOnboarding() {
        
    }
    
    //MARK:- Test
    @IBAction func loginTapped(_ sender: AnyObject) {
        TraktHelper.shared.login(from: self, success: { 
            TraktHelper.shared.getMyProfile(completion: { error, user in
                //Yay
                self.goToPlayback()
            })
            }) { (error) in
                //Boo
                KrangLogger.log.error("Error logging into Trakt: \(error)")
        }
    }
}

