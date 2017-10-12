//
//  KrangWatchableUI.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 10/11/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit
import LGAlertView

enum KrangWatchableAction {
    case none
    case checkIn
    case markWatched
    case markUnwatched
}

class KrangWatchableUI: NSObject {
    
    class func checkIn(toWatchable watchable: KrangWatchable, doCountdown: Bool, completion:((Error?, KrangWatchable?) -> ())?) {
        let _ = KrangActionableFullScreenAlertView.show(withTitle: "Checking in to \(watchable.title)", countdownDuration: (doCountdown ? 3.0 : 0.0), afterCountdownAction: { (alert) in
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
    
    class func offerActions(forWatchable watchable: KrangWatchable, completion:((Error?, KrangWatchableAction) -> ())?) {
        guard UserPrefs.traktSync else {
            KrangWatchableUI.checkIn(toWatchable: watchable, doCountdown: true, completion: { (error, checkedInWatchable) in
                completion?(error, .checkIn)
            })
            return
        }
        
        let alertView = LGAlertView(withWatchable: watchable, checkInHandler: { (_, _, _) in
            checkIn(toWatchable: watchable, doCountdown: false, completion: { (checkinError, checkedInWatchable) in
                completion?(checkinError, .checkIn)
            })
        }, markWatchedHandler: { (_, _, _) in
            //@TODO
            completion?(nil, .markWatched)
        }, markUnwatchedHandler: { (_, _, _) in
            //@TODO
            completion?(nil, .markUnwatched)
        }, cancelHandler: nil)
        alertView.showAnimated()
    }
}

extension LGAlertView {
    
    convenience init(withWatchable watchable: KrangWatchable, checkInHandler: LGAlertViewActionHandler? = nil, markWatchedHandler: LGAlertViewActionHandler? = nil, markUnwatchedHandler: LGAlertViewActionHandler? = nil, cancelHandler: LGAlertViewHandler? = nil) {
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
