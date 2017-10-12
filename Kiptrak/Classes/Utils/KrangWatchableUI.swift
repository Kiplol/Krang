//
//  KrangWatchableUI.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 10/11/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit
import LGAlertView

class KrangWatchableUI: NSObject {
    
    class func checkIn(toWatchable watchable: KrangWatchable, completion:((Error?, KrangWatchable?) -> ())?) {
        let _ = KrangActionableFullScreenAlertView.show(withTitle: "Checking in to \(watchable.title)", countdownDuration: 3.0, afterCountdownAction: { (alert) in
            alert.button.isHidden = true
            TraktHelper.shared.checkIn(to: watchable, completion: { (error, checkedInWatchable) in
                alert.dismiss(true) {
                    completion?(error, checkedInWatchable)
                }
            })
        }, buttonTitle: "Cancel Checkin", buttonAction: { (alert, _) in
            alert.dismiss(true)
        })
    }
}

extension LGAlertView {
    
    convenience init(withWatchable watchable: KrangWatchable, checkInHandler: LGAlertViewActionHandler? = nil, markWatchedHandler: LGAlertViewActionHandler? = nil, markUnwatchedHandler: LGAlertViewActionHandler? = nil) {
        let previewView = Bundle.main.loadNibNamed("KrangWatchablePreviewView", owner: nil, options: nil)![0] as! KrangWatchablePreviewView
        previewView.setWatchable(watchable)
        
        self.init(viewAndTitle: watchable.title, message: watchable.subtitle, style: .actionSheet, view: previewView, buttonTitles: ["Check In", "Mark Watched"], cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, actionHandler: { (alertView, index, title) in
            if let title = title {
                switch title {
                case "Check In":
                    checkInHandler?(alertView, index, title)
                case "Mark Watched":
                    markWatchedHandler?(alertView, index, title)
                case "Mark Unwatched":
                    markUnwatchedHandler?(alertView, index, title)
                default:
                    break
                }
            }
        }, cancelHandler: nil, destructiveHandler: nil)
    }
}
