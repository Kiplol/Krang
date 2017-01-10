//
//  ViewController.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/8/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit
import OAuthSwift

class SplashViewController: UIViewController {

    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if TraktHelper.shared.credentialsAreValid() {
            TraktHelper.shared.getMyProfile(completion: { error, user in
                //Peeee
            })
            self.goToHome()
        } else {
            
        }
    }
    
    //MARK:-
    private func goToHome() {
        
    }
    
    private func goToOnboarding() {
        
    }
    
    //MARK:- Test
    @IBAction func loginTapped(_ sender: AnyObject) {
        TraktHelper.shared.login(from: self, success: { 
            TraktHelper.shared.getMyProfile(completion: { error, user in
                //Yay
                self.goToHome()
            })
            }) { (error) in
                //Boo
                print(error)
        }
    }
}

