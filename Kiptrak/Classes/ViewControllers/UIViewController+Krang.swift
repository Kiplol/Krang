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
    class var defaultCollapsedDrawerHeight: CGFloat { return (68.0 + (KrangUtils.Display.typeIsLike == .iphoneX ? 25.0 : 0.0)) }
    
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
    
    public func collapsedDrawerHeight() -> CGFloat
    {
        if let drawer = self.topViewController as? PulleyDrawerViewControllerDelegate {
            return drawer.collapsedDrawerHeight()
        }
        return UIViewController.defaultCollapsedDrawerHeight
    }
    
    public func partialRevealDrawerHeight() -> CGFloat
    {
        if let drawer = self.topViewController as? PulleyDrawerViewControllerDelegate {
            return drawer.partialRevealDrawerHeight()
        }
        return UIViewController.defaultPartialRevealDrawerHeight
    }
    
    public func supportedDrawerPositions() -> [PulleyPosition] {
        if let drawer = self.topViewController as? PulleyDrawerViewControllerDelegate {
            return drawer.supportedDrawerPositions()
        }
        return PulleyPosition.all
    }
    
    public func drawerPositionDidChange(drawer: PulleyViewController)
    {
        if let drawerTopVC = self.topViewController as? PulleyDrawerViewControllerDelegate {
            drawerTopVC.drawerPositionDidChange?(drawer: drawer)
        }
    }
}
