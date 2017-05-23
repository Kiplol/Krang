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
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonLoginTrakt.alpha = 0.0
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
        self.performSegue(withIdentifier: "toPlayback", sender: nil)
    }
    
    private func goToOnboarding() {
        UIView.animate(withDuration: 0.3) { 
            self.buttonLoginTrakt.alpha = 1.0
        }
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
                KrangLogger.log.error("Error logging into Trakt: \(String(describing: error))")
        }
    }
}

