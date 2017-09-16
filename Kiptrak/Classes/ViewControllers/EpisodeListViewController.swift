//
//  EpisodeListViewController.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 9/16/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit
import RealmSwift

class EpisodeListViewController: KrangViewController, UITableViewDataSource, UITableViewDelegate {

    private static let cellReuseIdentifier = "episodeCell"
    
    //MARK:- IBOutlets
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            let nib = UINib(nibName: "EpisodeTableViewCell", bundle: Bundle.main)
            self.tableView.register(nib, forCellReuseIdentifier: EpisodeListViewController.cellReuseIdentifier)
        }
    }
    
    //MARK:- ivars
    var season: KrangSeason! {
        willSet {
            self.episodesNotificationToken?.stop()
            self.episodesNotificationToken = nil
        }
        didSet {
            if let show = season.show {
                self.title = "\(show.title) - \(season.title)"
            } else {
                self.title = season.title
            }
            self.episodesNotificationToken = self.season.episodes.addNotificationBlock() { change in
                if self.isViewLoaded {
                    switch change {
                    case .initial(_):
                        self.tableView.reloadData()
                    case .update(let results, deletions: let deletions, insertions: let insertions, modifications: let modifications):
                        self.tableView.beginUpdates()
                        self.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                        self.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                        for row in modifications {
                            let indexPath = IndexPath(row: row, section: 0)
                            let episode = results[indexPath.row]
                            if let cell = self.tableView.cellForRow(at: indexPath) as? EpisodeTableViewCell {
                                cell.update(withEpisode: episode)
                            }
                        }
                        self.tableView.endUpdates()
                    default:
                        break
                    }
                }
            }
        }
    }
    var episodesNotificationToken: NotificationToken? = nil
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        TraktHelper.shared.getAllEpisodes(forSeason: self.season) { (error, updatedSeason) in
            
        }
    }
    
    //MARK:- UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.season.episodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EpisodeListViewController.cellReuseIdentifier, for: indexPath)
        if let episodeCell = cell as? EpisodeTableViewCell {
            episodeCell.update(withEpisode: self.season.episodes[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    //MARK:- UITableViewDelegate

}
