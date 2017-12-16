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
import LGAlertView

class WatchableSearchViewController: KrangViewController, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate, SwipeTableViewCellDelegate {
    
    static let cellReuseIdentifier = "searchResultsCell"
    static var hasShownDemoSwipe: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "hasShownDemoSwipe")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "hasShownDemoSwipe")
            UserDefaults.standard.synchronize()
        }
    }

    // MARK :- IBOutlets
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            let nib = UINib(nibName: "WatchableSearchResultTableViewCell", bundle: Bundle.main)
            self.tableView.register(nib, forCellReuseIdentifier: WatchableSearchViewController.cellReuseIdentifier)
        }
    }
    
    // MARK :- ivars
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    fileprivate var searchResults = [KrangSearchable]()
    fileprivate var historyResults = [KrangSearchable]()
    fileprivate var searchRequest: OAuthSwiftRequestHandle? = nil
    var isSearching: Bool {
//        return self.searchController.isActive
        return !(self.searchController.searchBar.text ?? "").isEmpty
    }
    var dataSet: [KrangSearchable] {
        if self.isSearching {
            return self.searchResults
        } else {
            return self.historyResults
        }
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Search"
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "American Psycho, Law & Order, etc..."
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.applyKrangStyle()
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.definesPresentationContext = true
        self.navigationItem.titleView = self.searchController.searchBar
//        self.searchController.searchBar.frame = self.searchController.searchBar.superview!.bounds
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        self.searchController.searchBar.frame = self.searchController.searchBar.superview!.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.layoutIfNeeded()
        TraktHelper.shared.getRecentShowHistory { (error, shows) in
            self.historyResults = shows
            if !self.isSearching {
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK:- KrangViewController
    override func keyboardVisibleHeightDidChange(_ keyboardVisibleHeight: CGFloat) {
        if self.tableView != nil {
            self.tableView.contentInset.bottom = keyboardVisibleHeight
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
        return self.dataSet.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WatchableSearchViewController.cellReuseIdentifier)
        let searchable = self.dataSet[indexPath.row]
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
        let selectedObject = self.dataSet[indexPath.row]
        if let watchable = selectedObject as? KrangWatchable {
            //Hide keyboard.
            self.searchController.searchBar.resignFirstResponder()
            
            KrangWatchableUI.offerActions(forWatchable: watchable, completion: { (error, action) in
                switch action {
                case .checkIn:
                    if error == nil {
                        if let drawer = self.pulleyViewController {
                            drawer.setDrawerPosition(position: .collapsed, animated: true)
                        }
                    }
                    
                default:
                    break //@TODO: Other action
                }
            })
        } else if let show = selectedObject as? KrangShow {
            //Navigate to seasons VC.
            let seasonsVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "seasonList") as! SeasonListViewController
            seasonsVC.show = show
//            self.feedbackGeneratorForSelection.selectionChanged()
            self.navigationController?.pushViewController(seasonsVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let swipeCell = cell as? WatchableSearchResultTableViewCell, !WatchableSearchViewController.hasShownDemoSwipe, indexPath.row == 0 {
            var shouldShowDemoSwipeThisTime = true
            if let drawer = self.pulleyViewController {
                switch drawer.drawerPosition {
                case .closed, .collapsed:
                    shouldShowDemoSwipeThisTime = false
                default:
                    break
                }
            }
            if shouldShowDemoSwipeThisTime {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                swipeCell.showSwipe(orientation: .right, animated: true, completion: { (idunno) in
                    swipeCell.hideSwipe(animated: true) { _ in
                        WatchableSearchViewController.hasShownDemoSwipe = true
                    }
                })
            })
            }
        }
    }
    
    
    //MARK:- SwipeTableViewCellDelegate
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let selectedObject = self.dataSet[indexPath.row]
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
        
        self.feedbackGeneratorForSelection.selectionChanged()
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
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return UIViewController.defaultCollapsedDrawerHeight + bottomSafeArea
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return UIViewController.defaultPartialRevealDrawerHeight + bottomSafeArea
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return PulleyPosition.all // You can specify the drawer positions you support. This is the same as: [.open, .partiallyRevealed, .collapsed, .closed]
    }
    
    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        if self.isViewLoaded {
            self.tableView.isScrollEnabled = drawer.drawerPosition == .open
            if drawer.drawerPosition != .open {
                self.searchController.searchBar.resignFirstResponder()
            }
        }
    }
    
    func drawerChangedDistanceFromBottom(drawer: PulleyViewController, distance: CGFloat, bottomSafeArea: CGFloat) {
        let minDistance = self.collapsedDrawerHeight(bottomSafeArea: bottomSafeArea)
        let range: CGFloat = 160.0
        let t = (distance - minDistance) / range
    }
    
    //MARK:- UISearchBarDelegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
}
