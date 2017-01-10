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
            TraktHelper.shared.getMyProfile(completion: { 
                //Peeee
            })
        } else {
            
        }
    }
    


    @IBAction func loginTapped(_ sender: AnyObject) {
        
        TraktHelper.shared.login(from: self, success: { 
            TraktHelper.shared.getMyProfile(completion: { 
                //Yay
            })
            }) { (error) in
                //Boo
                print(error)
        }
    }
}

