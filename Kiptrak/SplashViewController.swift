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
    private var shouldLoginAfterAppear = false {
        didSet {
            if self.canLogin && shouldLoginAfterAppear {
                self.loginTapped(self)
                self.shouldLoginAfterAppear = false
            }
        }
    }
    private var canLogin = false {
        didSet {
            if self.canLogin && shouldLoginAfterAppear {
                self.loginTapped(self)
                self.shouldLoginAfterAppear = false
            }
        }
    }
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonLoginTrakt.alpha = 0.0
        self.imageBackground.alpha = 0.0
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        TMDBHelper.shared.getConfiguration { (error) in
            self.canLogin = true
            guard error == nil else {
                self.goToOnboarding()
                return
            }
            if TraktHelper.shared.credentialsAreValid() {
                TraktHelper.shared.getMyProfile(completion: { error, user in
                    //Peeee
                    if user != nil && user!.username.characters.count > 0 {
                        KrangLogger.log.debug("User \(user!.username) is already logged in, so proceed to playback")
//                        TraktHelper.shared.getFullHistory(since: user!.lastHistorySync, progress: { currentPage, numberOfPages in
//                            KrangLogger.log.debug("Got history page \(currentPage) of \(numberOfPages).")
//                        }, completion: { (historyError) in
//                            if historyError == nil {
//                                user!.makeChanges {
//                                    user!.lastHistorySync = Date()
//                                }
//                            }
//                        })
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
    
    func loginAfterAppear() {
        self.shouldLoginAfterAppear = true
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

