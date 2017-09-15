//
//  UIViewController+Krang.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 5/28/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit
import Pulley

extension UIViewController {
    
    func topViewController() -> UIViewController {
        if let presentedViewController = self.presentedViewController {
            return presentedViewController.topViewController()
        } else if let navController = self as? UINavigationController, let topVC = navController.topViewController {
            return topVC.topViewController()
        } else {
            return self
        }
    }
    
    var pulleyViewController: PulleyViewController? {
        return UIViewController.getPulleyViewController(containing: self)
    }
    
    fileprivate class func getPulleyViewController(containing viewController: UIViewController) -> PulleyViewController? {
        if let pulleyVC = viewController as? PulleyViewController {
            return pulleyVC
        } else if let parent = viewController.parent {
            return UIViewController.getPulleyViewController(containing: parent)
        }
        return nil
    }
}
