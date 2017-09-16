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

class WatchableSearchViewController: KrangViewController, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate {
    
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
        if let searchResultCell = cell as? WatchableSearchResultTableViewCell {
            searchResultCell.update(withSearchable: self.searchResults[indexPath.row])
        }
        return cell!
    }
    
    //MARK:- UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedObject = self.searchResults[indexPath.row]
        if let linkable = selectedObject as? KrangLinkable {
            let actionSheet = UIAlertController(title: linkable.title, message: nil, preferredStyle: .actionSheet)
            if let tmbdURL = linkable.urlForTMDB {
                actionSheet.addAction(UIAlertAction(title: "Open in TMDB", style: .default, handler: { (action) in
                    UIApplication.shared.open(tmbdURL, options: [:], completionHandler: nil)
                }))
            }
            if let traktURL = linkable.urlForTrakt {
                actionSheet.addAction(UIAlertAction(title: "Open in Trakt.TV", style: .default, handler: { (action) in
                    UIApplication.shared.open(traktURL, options: [:], completionHandler: nil)
                }))
            }
            if let imdbURL = linkable.urlForIMDB {
                actionSheet.addAction(UIAlertAction(title: "Open in IMDB", style: .default, handler: { (action) in
                    UIApplication.shared.open(imdbURL, options: [:], completionHandler: nil)
                }))
            }
            if let watchable = linkable as? KrangWatchable {
                actionSheet.addAction(UIAlertAction(title: "Check In", style: .default, handler: { (action) in
                    TraktHelper.shared.checkIn(to: watchable, completion: { (error, checkedInWatchable) in
                        if checkedInWatchable != nil {
                            if let drawer = self.pulleyViewController {
                                drawer.setDrawerPosition(position: .collapsed, animated: true)
                            }
                        }
                    })
                }))
            } else if let show = linkable as? KrangShow {
                actionSheet.addAction(UIAlertAction(title: "Check In", style: .default, handler: { (action) in
                    let lol = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "seasonList") as! SeasonListViewController
                    lol.show = show
                    self.navigationController?.pushViewController(lol, animated: true)
                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                }))
            }
            
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
            }))
            actionSheet.view.tintColor = UIColor.darkBackground
            self.present(actionSheet, animated: true, completion: nil)
        }
        
        if let show = selectedObject as? KrangShow {
            TraktHelper.shared.getAllSeasons(forShow: show, completion: { (error, updatedShow) in

            })
        }
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
