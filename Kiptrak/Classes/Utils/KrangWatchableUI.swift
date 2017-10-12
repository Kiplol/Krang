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
    
    convenience init(withWatchable watchable: KrangWatchable, actionHandler: LGAlertViewActionHandler? = nil, cancelHandler: LGAlertViewHandler? = nil) {
        let previewView = Bundle.main.loadNibNamed("KrangWatchablePreviewView", owner: nil, options: nil)![0] as! KrangWatchablePreviewView
        previewView.setWatchable(watchable)
        self.init(viewAndTitle: watchable.title, message: watchable.subtitle, style: .actionSheet, view: previewView, buttonTitles: ["Check In", "Mark Watched"], cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, actionHandler: actionHandler, cancelHandler: cancelHandler, destructiveHandler: nil)
    }
}
