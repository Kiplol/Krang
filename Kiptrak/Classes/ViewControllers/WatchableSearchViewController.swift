//
//  WatchableSearchViewController.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 9/13/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit
import Pulley
import RealmSwift
import OAuthSwift
import SwipeCellKit

class WatchableSearchViewController: KrangViewController, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate, SwipeTableViewCellDelegate {
    
    static let cellReuseIdentifier = "searchResultsCell"

    //MARK:- IBOutlets
    @IBOutlet weak var grabberView: UIView!
    @IBOutlet weak var searchBarContainerView: UIView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            let nib = UINib(nibName: "WatchableSearchResultTableViewCell", bundle: Bundle.main)
            self.tableView.register(nib, forCellReuseIdentifier: WatchableSearchViewController.cellReuseIdentifier)
        }
    }
    @IBOutlet weak var constraintSearchBarContainerHeight: NSLayoutConstraint!
    
    //MARK:- ivars
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    fileprivate var searchResults = [KrangSearchable]()
    fileprivate var searchRequest: OAuthSwiftRequestHandle? = nil
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Search"
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "American Psycho, Law & Order, etc..."
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.applyKrangStyle()
        self.definesPresentationContext = true
        self.searchBarContainerView.addSubview(self.searchController.searchBar)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.pulleyViewController != nil {
            self.navigationController?.setNavigationBarHidden(true, animated: animated)
        }
    }
    
    //MARK:- UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        self.searchRequest?.cancel()
        self.searchRequest = TraktHelper.shared.search(withQuery: searchController.searchBar.text ?? "") { (error, results) in
            self.searchResults.removeAll()
            self.searchResults.append(contentsOf: results)
            self.tableView.reloadData()
        }
    }
    
    //MARK:- UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WatchableSearchViewController.cellReuseIdentifier)
        let searchable = self.searchResults[indexPath.row]
        if let searchResultCell = cell as? WatchableSearchResultTableViewCell {
            searchResultCell.update(withSearchable: searchable)
            searchResultCell.delegate = self
            switch searchable {
            case is KrangShow:
                searchResultCell.accessoryType = .disclosureIndicator
            default:
                searchResultCell.accessoryType = .none
            }
        }
        return cell!
    }
    
    //MARK:- UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedObject = self.searchResults[indexPath.row]
        if let watchable = selectedObject as? KrangWatchable {
            TraktHelper.shared.checkIn(to: watchable, completion: { (error, checkedInWatchable) in
                if checkedInWatchable != nil {
                    if let drawer = self.pulleyViewController {
                        drawer.setDrawerPosition(position: .collapsed, animated: true)
                    }
                }
            })
        } else if let show = selectedObject as? KrangShow {
            let seasonsVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "seasonList") as! SeasonListViewController
            seasonsVC.show = show
            self.navigationController?.pushViewController(seasonsVC, animated: true)
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    //MARK:- SwipeTableViewCellDelegate
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let selectedObject = self.searchResults[indexPath.row]
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

extension WatchableSearchViewController: PulleyDrawerViewControllerDelegate, UISearchBarDelegate {
    //MARK:- PulleyDrawerViewControllerDelegate
    func collapsedDrawerHeight() -> CGFloat
    {
        if self.isViewLoaded {
            return self.searchBarContainerView.frame.maxY
        } else {
            return 68.0
        }
    }
    
    func partialRevealDrawerHeight() -> CGFloat
    {
        if self.isViewLoaded {
            let rowHeight = self.tableView.rowHeight
            let maxHeight = 2.5 * rowHeight
            let minHeight = rowHeight * 1.5
            let searchResultsHeight = (max(1.0, CGFloat(self.searchResults.count)) - 0.5) * rowHeight
            let tableViewHeight = max(minHeight, min(maxHeight, searchResultsHeight))
            let searchBarHeight = self.searchBarContainerView.frame.maxY
            return tableViewHeight + searchBarHeight
        } else {
            return 264.0
        }
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return PulleyPosition.all // You can specify the drawer positions you support. This is the same as: [.open, .partiallyRevealed, .collapsed, .closed]
    }
    
    func drawerPositionDidChange(drawer: PulleyViewController)
    {
        if self.isViewLoaded {
            self.tableView.isScrollEnabled = drawer.drawerPosition == .open
            if drawer.drawerPosition != .open {
                self.searchController.searchBar.resignFirstResponder()
            }
        }
    }
    
    //MARK:- UISearchBarDelegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        if let drawerVC = self.pulleyViewController
        {
            drawerVC.setDrawerPosition(position: .open, animated: true)
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if let drawerVC = self.pulleyViewController
        {
            drawerVC.setDrawerPosition(position: .collapsed, animated: true)
        }
    }
}
