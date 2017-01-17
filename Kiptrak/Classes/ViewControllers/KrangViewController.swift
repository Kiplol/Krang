//
//  KrangViewController.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/9/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit
import Hero

class KrangViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.darkBackground
        
        NotificationCenter.default.addObserver(self, selector: #selector(KrangViewController.willEnterForeground(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KrangViewController.didEnterBackground(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- App Licecyle
    func willEnterForeground(_ notif:Notification) {
        //Override
    }
    
    func didEnterBackground(_ notif:Notification) {
        //Override
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
