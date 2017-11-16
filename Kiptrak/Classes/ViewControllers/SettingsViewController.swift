//
//  SettingsViewController.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/10/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit

class SettingsViewController: KrangViewController, UITableViewDataSource, UITableViewDelegate {

    //MARK:- IBoutlets
    @IBOutlet weak var imageCover: UIImageView! {
        didSet {
            self.imageCover.setCoverImage(fromURL: KrangUser.getCurrentUser().coverImageURL)
            self.imageCover.heroModifiers = [.translate(x: 0.0, y: -200.0, z: 0.0), .zPosition(0.0)]
        }
    }
    @IBOutlet weak var avatar: KrangAvatarView! {
        didSet {
            self.avatar.heroModifiers = [.arc(intensity: 0.5), .zPosition(10.0)]
        }
    }
    @IBOutlet weak var buttonClose: UIButton! {
        didSet {
            self.buttonClose.heroModifiers = [.zPosition(12.0), .translate(x: 0.0, y: -200.0, z: 0.0)]
        }
    }
    @IBOutlet weak var shadowTop: UIImageView! {
        didSet {
            self.shadowTop.image = UIImage(gradientColors: [UIColor(white: 0.0, alpha: 0.7) , UIColor.clear])
            self.shadowTop.heroModifiers = [.fade, .translate(x: 0.0, y: -80.0, z: 0.0)]
        }
    }
    @IBOutlet weak var labelName: UILabel! {
        didSet {
            self.labelName.heroModifiers = [.fade, .translate(x: 0.0, y: -50.0, z: 0.0)]
        }
    }
    @IBOutlet weak var footerView: UIView! {
        didSet {
            self.footerView.heroModifiers = [.fade, .translate(x: 0.0, y: 70.0, z: 0.0)]
        }
    }
    @IBOutlet weak var constraintBelowStackView: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- Ivars
    fileprivate var rows = [Row]()
    fileprivate class Row {
        let reuseID = "text"
    }
    fileprivate class LogoutRow: Row { }
    fileprivate class VersionRow: Row {
        let versionString = KrangUtils.versionAndBuildNumberString
    }
    fileprivate class TraktSyncRow: Row {
        var isOn = false
        
        convenience init(isOn: Bool) {
            self.init()
            self.isOn = isOn
        }
    }
    fileprivate static let tagTraktSyncSwitch = 10
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.populateViews()
        self.constraintBelowStackView.constant = (16.0 + KrangUtils.safeAreaInsets.bottom)
    }
    
    //MARK:-
    private func populateViews() {
        self.labelName.text = KrangUser.getCurrentUser().name
        self.rows.removeAll()
        self.rows.append(LogoutRow())
        self.rows.append(VersionRow())
        self.rows.append(TraktSyncRow(isOn: UserPrefs.traktSync))
    }
    
    private func logout() {
        self.performSegue(withIdentifier: "unwindToSplashSegueID", sender: self)
    }
    
    //MARK:- UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = self.rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseID, for: indexPath)
        switch row {
        case is LogoutRow:
            cell.textLabel?.text = "Logout"
            cell.detailTextLabel?.text = nil
            cell.accessoryType = .disclosureIndicator
        case is VersionRow:
            cell.textLabel?.text = "Krang Version"
            cell.detailTextLabel?.text = (row as! VersionRow).versionString
            cell.accessoryType = .none
        case is TraktSyncRow:
            cell.textLabel?.text = "Sync Trakt History"
            cell.detailTextLabel?.text = nil
            let switchView = (cell.accessoryView as? UISwitch ?? UISwitch())
            switchView.isOn = UserPrefs.traktSync
            switchView.tag = SettingsViewController.tagTraktSyncSwitch
            switchView.addTarget(self, action: #selector(SettingsViewController.switchSwitched(switchView:)), for: .valueChanged)
            cell.accessoryView = switchView
        default:
            break
        }
        return cell
    }
    
    //MARK:- UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = self.rows[indexPath.row]
        switch row {
        case is LogoutRow:
            self.logout()
        default:
            break
        }
    }
    
    //MARK:- UISwitch
    func switchSwitched(switchView: UISwitch) {
        switch switchView.tag {
        case SettingsViewController.tagTraktSyncSwitch:
            KrangLogger.log.debug("Trakt Sync turned \(switchView.isOn ? "on" : "off")")
            if switchView.isOn {
                let fullscreenAlertView = KrangActionableFullScreenAlertView.show(withTitle: "Syncing with Trakt", countdownDuration: 3.0, afterCountdownAction: { (alert) in
                    alert.button.isHidden = true
                    TraktHelper.shared.getFullHistory(since: Date.distantPast, progress: { (currentPage, maxPage) in
                        //@TODO: Animate this
                        alert.progressView.progress = Double(currentPage) / Double(maxPage)
                    }, completion: { (error) in
                        RealmManager.makeChanges {
                            KrangUser.getCurrentUser().lastHistorySync = Date()
                        }
                        UserPrefs.traktSync = switchView.isOn
                        alert.dismiss(true)
                    })
                }, buttonTitle: "Cancel Sync", buttonAction: { (alert, _) in
                    alert.dismiss(true)
                })
                fullscreenAlertView?.indeterminate = false
            } else {
                UserPrefs.traktSync = switchView.isOn
                RealmManager.makeChanges {
                    KrangUser.getCurrentUser().lastHistorySync = Date.distantPast
                    RealmManager.removeAllWatchDates()
                }
            }
        default:
            break
        }
    }
}
