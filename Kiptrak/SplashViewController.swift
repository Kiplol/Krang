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

    @IBOutlet weak var buttonLoginTrakt: UIButton!
    @IBOutlet weak var imageBackground: UIImageView!
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonLoginTrakt.alpha = 0.0
        self.imageBackground.alpha = 0.0
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        TMDBHelper.shared.getConfiguration { (error) in
            guard error == nil else {
                self.goToOnboarding()
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
                self.goToOnboarding()
            }
        }
    }
    
    //MARK:-
    private func goToPlayback() {
        self.performSegue(withIdentifier: "toPlayback", sender: nil)
    }
    
    private func goToOnboarding() {
        UIView.animate(withDuration: 0.6) {
            self.buttonLoginTrakt.alpha = 1.0
        }
        UIView.animate(withDuration: 3.0) {
            self.imageBackground.alpha = 1.0
        }
    }
    
    //MARK:- 
    @IBAction func loginTapped(_ sender: AnyObject) {
        TraktHelper.shared.login(from: self, success: { 
            TraktHelper.shared.getMyProfile(completion: { error, user in
                //Yay
                self.goToPlayback()
            })
            }) { (error) in
                //Boo
                KrangLogger.log.error("Error logging into Trakt: \(String(describing: error))")
        }
    }
    
    // MARK: - Navigation
    @IBAction func unwindToSplash(_ sender:UIStoryboardSegue) {
        //Logout
        TraktHelper.shared.logout()
        self.goToOnboarding()
    
    }
}

