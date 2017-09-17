//
//  KrangActionableFullScreenAlertView.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 9/16/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit
import KDCircularProgress

class KrangActionableFullScreenAlertView: UIView {

    //MARK:- IBOutlets
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var centerContainerView: UIView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var progressView: KDCircularProgress!
    
    //MARK:- ivars
    var title: String? = nil
    var countDownDuration: TimeInterval? = nil
    var buttonAction: ((KrangActionableFullScreenAlertView, UIButton) -> ())? = nil
    var afterCountdownAction: ((KrangActionableFullScreenAlertView) -> ())? = nil
    var startTime: Date? = nil
    var displayLink: CADisplayLink? = nil
    
    func dismiss(_ animated: Bool, completion: (() -> ())? = nil) {
        self.displayLink?.invalidate()
        let duration: TimeInterval = animated ? 0.3 : 0.0
        UIView.animate(withDuration: duration, animations: { 
            self.alpha = 0.0
        }) { (_) in
            self.removeFromSuperview()
            self.alpha = 1.0
            completion?()
        }
    }
    
    func startCountdown() {
        guard let duration = self.countDownDuration else {
            return
        }
        
        if let oldDisplayLink = self.displayLink {
            oldDisplayLink.invalidate()
        }
        
        self.startTime = Date()
        self.displayLink = CADisplayLink(target: self, selector: #selector(KrangActionableFullScreenAlertView.displayLinkTick))
        self.displayLink!.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    func displayLinkTick() {
        guard let startTime = self.startTime, let duration = self.countDownDuration else {
            self.displayLink?.invalidate()
            return
        }
        
        let timeElapsed = Date().timeIntervalSince1970 - startTime.timeIntervalSince1970
        if timeElapsed < duration {
            let secondsLeft = String(format: "%.2f", duration - timeElapsed)
            self.labelTitle.text = "\(self.title != nil ? self.title! + " in " : "")\(secondsLeft)"
            let progress = timeElapsed / duration
            self.progressView.progress = 1.0 - progress
        } else {
            self.labelTitle.text = self.title
            self.afterCountdownAction?(self)
            self.afterCountdownAction = nil
            self.progressView.progress = 1.0 / 3.0
            self.progressView.startAngle = timeElapsed * 100.0
        }
    }

    //MARK:- UIView
    override func layoutSubviews() {
        super.layoutSubviews()
        self.centerContainerView.roundCorners()
        self.labelTitle.textColor = UIColor.black
        self.labelTitle.text = self.title
    }
    
    //MARK:- User Interaction
    @IBAction func buttonTapped(_ sender: Any) {
        self.displayLink?.invalidate()
        self.buttonAction?(self, self.button)
    }
    
    //MARK:- Helpers
    class func show(withTitle title: String?, countdownDuration: TimeInterval?, afterCountdownAction: ((KrangActionableFullScreenAlertView) -> ())?, buttonTitle: String? = nil, buttonAction: ((KrangActionableFullScreenAlertView, UIButton) -> ())? = nil) -> KrangActionableFullScreenAlertView? {
        
        guard let window = AppDelegate.instance.window else {
            return nil
        }
        
        let alert = Bundle.main.loadNibNamed("KrangActionableFullScreenAlertView", owner: nil, options: nil)![0] as! KrangActionableFullScreenAlertView
        alert.title = title
        if let buttonAction = buttonAction {
            alert.button.setTitle(buttonTitle ?? "Action", for: .normal)
            alert.buttonAction = buttonAction
        }
        alert.countDownDuration = countdownDuration
        alert.afterCountdownAction = afterCountdownAction
        alert.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        alert.alpha = 0.0
        window.addSubview(alert)
        UIView.animate(withDuration: 0.15, animations: { 
            alert.alpha = 1.0
        }) { (_) in
            alert.startCountdown()
        }
        return alert
    }
    
}
