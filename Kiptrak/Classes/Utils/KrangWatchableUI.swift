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
                KrangUtils.playFeedback(forResult: checkinError)
                completion?(checkinError, .checkIn)
            })
        }, markWatchedHandler: { (_, _, _) in
            TraktHelper.shared.markWatched(watchable, completion: { (markWatchedError) in
                KrangUtils.playFeedback(forResult: markWatchedError)
                completion?(markWatchedError, .markWatched)
            })
        }, markUnwatchedHandler: { (_, _, _) in
            TraktHelper.shared.markUnwatched(watchable, completion: { (markUnwatchedError) in
                KrangUtils.playFeedback(forResult: markUnwatchedError)
                completion?(markUnwatchedError, .markUnwatched)
            })
        }, cancelHandler: nil)
        alertView.showAnimated()
    }
}

extension LGAlertView {
    
    convenience init(withWatchable watchable: KrangWatchable, checkInHandler: LGAlertViewActionHandler? = nil, markWatchedHandler: LGAlertViewActionHandler? = nil, markUnwatchedHandler: LGAlertViewActionHandler? = nil, cancelHandler: LGAlertViewHandler? = nil) {
        let previewView = Bundle.main.loadNibNamed("KrangWatchablePreviewView", owner: nil, options: nil)![0] as! KrangWatchablePreviewView
        previewView.setWatchable(watchable)
        
        let checkInTitle = "Check In"
        let markWatchedTitle = "Mark Watched"
        let markUnwatchedTitle = "Mark Unwatched"
        var buttonsTitles: [String] = [checkInTitle]
        if UserPrefs.traktSync {
            if watchable.watchDate == nil {
                buttonsTitles.append(markWatchedTitle)
            } else {
                buttonsTitles.append(markUnwatchedTitle)
            }
        }
        
        self.init(viewAndTitle: watchable.title, message: watchable.subtitle, style: .actionSheet, view: previewView, buttonTitles: buttonsTitles, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, actionHandler: { (alertView, index, title) in
            if let title = title {
                switch title {
                case checkInTitle:
                    checkInHandler?(alertView, index, title)
                case markWatchedTitle:
                    markWatchedHandler?(alertView, index, title)
                case markUnwatchedTitle:
                    markUnwatchedHandler?(alertView, index, title)
                default:
                    break
                }
            }
        }, cancelHandler: nil, destructiveHandler: nil)
    }
}
