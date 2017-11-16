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
    
    class var defaultPartialRevealDrawerHeight: CGFloat { return 300.0 }
    class var defaultCollapsedDrawerHeight: CGFloat { return 82.0 }
    
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

extension UINavigationController: PulleyDrawerViewControllerDelegate {
    public func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        if let drawer = self.topViewController as? PulleyDrawerViewControllerDelegate {
            return drawer.collapsedDrawerHeight(bottomSafeArea: bottomSafeArea)
        }
        return UIViewController.defaultCollapsedDrawerHeight + bottomSafeArea
    }
    
    public func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        if let drawer = self.topViewController as? PulleyDrawerViewControllerDelegate {
            return drawer.partialRevealDrawerHeight(bottomSafeArea: bottomSafeArea)
        }
        return UIViewController.defaultPartialRevealDrawerHeight + bottomSafeArea
    }
    
    public func supportedDrawerPositions() -> [PulleyPosition] {
        if let drawer = self.topViewController as? PulleyDrawerViewControllerDelegate {
            return drawer.supportedDrawerPositions()
        }
        return PulleyPosition.all
    }
    
    public func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        if let drawerTopVC = self.topViewController as? PulleyDrawerViewControllerDelegate {
            drawerTopVC.drawerPositionDidChange?(drawer: drawer, bottomSafeArea: bottomSafeArea)
        }
    }
    
    public func drawerChangedDistanceFromBottom(drawer: PulleyViewController, distance: CGFloat, bottomSafeArea: CGFloat) {
        if let drawerTopVC = self.topViewController as? PulleyDelegate {
            drawerTopVC.drawerChangedDistanceFromBottom?(drawer: drawer, distance: distance, bottomSafeArea: bottomSafeArea)
        }
    }
}
