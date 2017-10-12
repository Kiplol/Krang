//
//  EpisodeListViewController.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 9/16/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import Pulley

class EpisodeListViewController: KrangViewController, UITableViewDataSource, UITableViewDelegate, SwipeTableViewCellDelegate {

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
        didSet {
            self.episodes = self.season.getEpisodesInOrder()
            self.title = season.title
        }
    }
    var episodesNotificationToken: NotificationToken? = nil
    fileprivate var episodes: Results<KrangEpisode>! {
        willSet {
            self.episodesNotificationToken?.stop()
            self.episodesNotificationToken = nil
        }
        didSet {
            self.episodesNotificationToken = self.episodes.addNotificationBlock() { change in
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
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        TraktHelper.shared.getAllEpisodes(forSeason: self.season) { (error, updatedSeason) in
            
        }
    }
    
    //MARK:- UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.episodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EpisodeListViewController.cellReuseIdentifier, for: indexPath)
        if let episodeCell = cell as? EpisodeTableViewCell {
            episodeCell.update(withEpisode: self.episodes[indexPath.row])
            episodeCell.delegate = self
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
    //MARK:- UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let episode = self.episodes[indexPath.row]
        KrangWatchableUI.offerActions(forWatchable: episode) { (error, action) in
            if error == nil {
                if let drawer = self.pulleyViewController {
                    drawer.setDrawerPosition(position: .collapsed, animated: true)
                }
            }
        }
    }
    
    //MARK:- SwipeTableViewCellDelegate
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let selectedObject = self.episodes[indexPath.row]
        var options = [SwipeAction]()
        if let linkable = selectedObject as? KrangLinkable {
            if let tmbdURL = linkable.urlForTMDB {
                let tmdbAction = SwipeAction(style: .default, title: "TMDB") { action, indexPath in
                    UIApplication.shared.open(tmbdURL, options: [:], completionHandler: nil)
                }
                tmdbAction.image = #imageLiteral(resourceName: "logo_tmdb_70_color")
                tmdbAction.backgroundColor = UIColor.tmdbBrandPrimaryDark
                tmdbAction.textColor = UIColor.tmdbBrandPrimaryLight
                tmdbAction.title = nil
                options.append(tmdbAction)
            }
            if let traktURL = linkable.urlForTrakt {
                let traktAction = SwipeAction(style: .default, title: "Trakt") { action, indexPath in
                    UIApplication.shared.open(traktURL, options: [:], completionHandler: nil)
                }
                traktAction.image = #imageLiteral(resourceName: "logo_trakt_70_color")
                traktAction.backgroundColor = UIColor.black
                traktAction.textColor = UIColor.traktBrandPrimary
                traktAction.title = nil
                options.append(traktAction)
            }
            if let imdbURL = linkable.urlForIMDB {
                let imdbAction = SwipeAction(style: .default, title: "IMDb") { action, indexPath in
                    UIApplication.shared.open(imdbURL, options: [:], completionHandler: nil)
                }
                imdbAction.image = #imageLiteral(resourceName: "logo_imdb_70_color")
                imdbAction.backgroundColor = UIColor.imdbBrandPrimary
                imdbAction.textColor = UIColor.black
                imdbAction.title = nil
                options.append(imdbAction)
            }
        }
        
        return options.isEmpty ? nil : options
    }

    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.transitionStyle = .drag
        return options
    }

}

extension EpisodeListViewController: PulleyDrawerViewControllerDelegate {
    //MARK:- PulleyDrawerViewControllerDelegate
    func collapsedDrawerHeight() -> CGFloat
    {
        return UIViewController.defaultCollapsedDrawerHeight
    }
    
    func partialRevealDrawerHeight() -> CGFloat
    {
        return UIViewController.defaultPartialRevealDrawerHeight
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return PulleyPosition.all
    }
    
    func drawerPositionDidChange(drawer: PulleyViewController)
    {
        if self.isViewLoaded {
            self.tableView.isScrollEnabled = drawer.drawerPosition == .open
        }
    }
}
