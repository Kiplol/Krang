//
//  SeasonListViewController.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 9/15/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit
import RealmSwift

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
            self.seasonsNotificationToken?.stop()
            self.seasonsNotificationToken = nil
        }
        didSet {
            self.title = show.title
            self.seasonsNotificationToken = self.show.seasons.addNotificationBlock() {change in
                if self.isViewLoaded {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    var seasonsNotificationToken: NotificationToken? = nil
    
    //MAARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        TraktHelper.shared.getAllSeasons(forShow: self.show) { (error, updatedShow) in
            
        }
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
