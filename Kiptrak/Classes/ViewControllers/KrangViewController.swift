//
//  KrangViewController.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/9/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit
import Hero
import RxSwift
import RxKeyboard

class KrangViewController: UIViewController {

    //MARK:- ivars
    fileprivate let disposeBag = DisposeBag()
    let feedbackGeneratorForSelection = UISelectionFeedbackGenerator()
    let feedbackGeneratorForNotifications = UINotificationFeedbackGenerator()
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.darkBackground
        
        NotificationCenter.default.addObserver(self, selector: #selector(KrangViewController.willEnterForeground(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KrangViewController.didEnterBackground(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { keyboardVisibleHeight in
                self.keyboardVisibleHeightDidChange(keyboardVisibleHeight)
            }).disposed(by: self.disposeBag)
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

    //MARK:- Convenience
    func keyboardVisibleHeightDidChange(_ keyboardVisibleHeight: CGFloat) {
        //Override
    }
}
