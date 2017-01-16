//
//  TodayViewController.swift
//  Currently Watching Widget
//
//  Created by Elliott Kipper on 1/15/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    //MARK:- ivars
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var imageBackground: UIImageView!
    @IBOutlet weak var imagePoster: UIImageView!
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let _ = RealmManager.shared
        KrangLogger.setup()
        
        //TODO: Appearance
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- NCWidgetProviding
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        
        let afterGettingTMDBConfiguartion = {
            TraktHelper.shared.getCheckedInMovieOrEpisode { (error, movie, episode) in
                guard error == nil else {
                    completionHandler(NCUpdateResult.failed)
                    return
                }
                
                var backgroundImageURL:URL? = nil
                var posterImageURL:URL? = nil
                if let movie = movie {
                    self.labelTitle.text = movie.titleDisplayString
                    if let backdropThumbnailURL = movie.backdropThumbnailImageURL {
                        backgroundImageURL = URL(string: backdropThumbnailURL)
                    }
                    if let posterThumbnailURL = movie.posterThumbnailImageURL {
                        posterImageURL = URL(string: posterThumbnailURL)
                    }
                } else if let episode = episode {
                    self.labelTitle.text = episode.titleDisplayString
                    if let stillThumbnailURL = episode.stillThumbnailImageURL {
                        backgroundImageURL = URL(string: stillThumbnailURL)
                    }
                    if let posterThumbnailURL = episode.posterThumbnailImageURL {
                       posterImageURL = URL(string: posterThumbnailURL)
                    }
                } else {
                    self.labelTitle.text = "Not Currently Watching Anything"
                    self.imageBackground.image = nil
                    completionHandler(.noData)
                    return
                }
                
                let group = DispatchGroup()
                
                group.enter()
                group.enter()
                self.imageBackground.kf.setImage(with: backgroundImageURL, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
                    group.leave()
                })
                self.imagePoster.kf.setImage(with: posterImageURL, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
                    group.leave()
                })
                
                group.notify(queue: DispatchQueue.main, execute: { 
                    completionHandler(.newData)
                })
            }
        }
        
        if TMDBHelper.shared.gotConfiguration {
            afterGettingTMDBConfiguartion()
        } else {
            TMDBHelper.shared.getConfiguration(completion: { (error) in
                afterGettingTMDBConfiguartion()
            })
        }
    }
    
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return .zero
    }
    
}
