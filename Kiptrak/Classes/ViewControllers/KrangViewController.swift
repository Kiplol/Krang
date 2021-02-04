//
//  KrangViewController.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/9/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import Hero
import RxKeyboard
import RxSwift
import UIKit

class KrangViewController: UIViewController {

    //MARK:- ivars
    fileprivate let disposeBag = DisposeBag()
    let feedbackGeneratorForSelection = UISelectionFeedbackGenerator()
    let feedbackGeneratorForNotifications = UINotificationFeedbackGenerator()
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.darkBackground
        
        NotificationCenter.default.addObserver(self, selector: #selector(KrangViewController.willEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KrangViewController.didEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
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
    @objc func willEnterForeground(_ notif:Notification) {
        //Override
    }
    
    @objc func didEnterBackground(_ notif:Notification) {
        //Override
    }

    //MARK:- Convenience
    func keyboardVisibleHeightDidChange(_ keyboardVisibleHeight: CGFloat) {
        //Override
    }
}
