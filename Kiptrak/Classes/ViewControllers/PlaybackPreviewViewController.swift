//
//  PlaybackPreviewViewController.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 12/24/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit

class PlaybackPreviewViewController: KrangViewController {
    
    // MARK: - ivars
    private var watchable: KrangWatchable? {
        didSet {
            self.layout(withWatchable: self.watchable)
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var labelWatchableDisplayName: UILabel!
    @IBOutlet weak var imagePoster: UIImageView!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(PlaybackPreviewViewController.didCheckInToAWatchable(_:)), name: Notification.Name.didCheckInToWatchable, object: nil)
    }
    
    // MARK: -
    func layout(withWatchable watchable: KrangWatchable?) {
        guard let watchable = watchable else {
            self.labelWatchableDisplayName.text = nil
            self.imagePoster.image = nil
            return
        }
        
        self.labelWatchableDisplayName.text = watchable.titleDisplayString
        self.imagePoster.setPoster(fromWatchable: self.watchable)
    }

    // MARK: - Notifications
    @objc func didCheckInToAWatchable(_ notif: Notification) {
        self.watchable = (notif.object as? KrangWatchable)
    }
    
    // MARK: - Navigation
    @IBAction func unwindToPlaybackPreview(_ sender:UIStoryboardSegue) {

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let playbackVC = segue.destination as? PlaybackViewController {
            playbackVC.watchable = self.watchable
        }
    }
}

extension PlaybackPreviewViewController: KrangDrawerViewControllerDelegate {
    func drawerViewController(_ drawerViewController: KrangDrawerViewController, willChangeStateTo state: KrangDrawerViewController.State) {
        switch state {
        case .open:
            self.performSegue(withIdentifier: "showFullPlayback", sender: self)
        default:
            break
        }
    }
    
    func drawerViewController(_ drawerViewController: KrangDrawerViewController, didChangeStateTo state: KrangDrawerViewController.State) {
        
    }
}
