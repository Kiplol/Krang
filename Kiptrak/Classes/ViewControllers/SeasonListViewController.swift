//
//  SeasonListViewController.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 9/15/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit
import RealmSwift
import Pulley

class SeasonListViewController: KrangViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    fileprivate static let cellReuseIdentifier = "seasonCell"
    //MARK:- IBOutlets
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            let nib = UINib(nibName: "SeasonCollectionViewCell", bundle: Bundle.main)
            self.collectionView.register(nib, forCellWithReuseIdentifier: SeasonListViewController.cellReuseIdentifier)
        }
    }
    
    //MARK:- ivars
    var show: KrangShow! {
        willSet {
            self.seasonsNotificationToken?.invalidate()
            self.seasonsNotificationToken = nil
        }
        didSet {
            self.title = show.title
            self.seasonsNotificationToken = self.show.seasons.observe() {change in
                if self.isViewLoaded {
                    switch change {
                    case .initial(_):
                        self.collectionView.reloadData()
                    case .update(let results, deletions: let deletions, insertions: let insertions, modifications: let modifications):
                        self.collectionView.performBatchUpdates({ 
                            self.collectionView.insertItems(at: insertions.map { IndexPath(row: $0, section: 0) })
                            self.collectionView.deleteItems(at: deletions.map { IndexPath(row: $0, section: 0) })
                            for row in modifications {
                                let indexPath = IndexPath(row: row, section: 0)
                                let season = results[indexPath.row]
                                if let cell = self.collectionView.cellForItem(at: indexPath) as? SeasonCollectionViewCell {
                                    cell.update(withSeason: season)
                                }
                            }
                        }, completion: nil)
                    default:
                        break
                    }
                    
                }
            }
        }
    }
    var seasonsNotificationToken: NotificationToken? = nil
    
    //MAARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        TraktHelper.shared.getAllSeasons(forShow: self.show) { (error, updatedShow) in
            if UserPrefs.traktSync {
                TraktHelper.shared.getHistory(forShow: self.show, completion: { (historyError, updatedShow) in
                    self.collectionView.reloadData()
                })
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    //MARK:- UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.show.seasons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SeasonListViewController.cellReuseIdentifier, for: indexPath) as! SeasonCollectionViewCell
        cell.update(withSeason: self.show.seasons[indexPath.row])
        return cell
    }
    
    //MARK:- UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let season = self.show.seasons[indexPath.row]
        let episodesVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "episodeList") as! EpisodeListViewController
        episodesVC.season = season
//        self.feedbackGeneratorForSelection.selectionChanged()
        self.navigationController?.pushViewController(episodesVC, animated: true)
    }
    
    //MARK:- UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let season = self.show.seasons[indexPath.row]
        return SeasonCollectionViewCell.size(forCollectionView: collectionView, withData: season)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}

extension SeasonListViewController: PulleyDrawerViewControllerDelegate {
    //MARK:- PulleyDrawerViewControllerDelegate
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return UIViewController.defaultCollapsedDrawerHeight
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return UIViewController.defaultPartialRevealDrawerHeight
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return PulleyPosition.all
    }
    
    func drawerPositionDidChange(drawer: PulleyViewController)
    {
        if self.isViewLoaded {
            self.collectionView.isScrollEnabled = drawer.drawerPosition == .open
        }
    }
}
