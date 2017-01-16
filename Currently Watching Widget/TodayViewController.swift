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
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let _ = RealmManager.shared
        KrangLogger.setup()
        
        //TODO: Centralize this with app
        UIWindow.appearance().tintColor = UIColor.orange
        UIView.appearance().tintColor = UIColor.orange
        
        //Navigation Bar
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        UINavigationBar.appearance().barTintColor = UIColor.darkBackground
        UINavigationBar.appearance().isTranslucent = false
        
        //Labels
        UILabel.appearance().textColor = UIColor.white
        UILabel.appearance().font = UIFont(name: "Exo-Black", size: 15.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        
        let afterGettingTMDBConfiguartion = {
            TraktHelper.shared.getCheckedInMovieOrEpisode { (error, movie, episode) in
                guard error == nil else {
                    completionHandler(NCUpdateResult.failed)
                    return
                }
                
                var imageURL:URL? = nil
                if let movie = movie {
                    self.labelTitle.text = movie.titleDisplayString
                    imageURL = movie.mainImageURL
                } else if let episode = episode {
                    self.labelTitle.text = episode.titleDisplayString
                    imageURL = episode.mainImageURL
                } else {
                    self.labelTitle.text = "Not Currently Watching Anything"
                    self.imageBackground.image = nil
                    completionHandler(.noData)
                    return
                }
                
//                self.imageBackground.kf.setImage(with: imageURL)
                completionHandler(.newData)
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
    
}
