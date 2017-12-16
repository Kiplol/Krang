//
//  KrangViewUtils.swift
//  Kiptrak
//
//  Created by Elliott Kipper on 1/16/17.
//  Copyright © 2017 Supernovacaine Inc. All rights reserved.
//

import UIKit

//@IBDesignable
extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var shadowColor: UIColor? {
        get {
            if let color = self.layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            guard let color = newValue else {
                self.layer.shadowColor = nil
                return
            }
            self.layer.shadowColor = color.cgColor
        }
    }
    
    @IBInspectable var shadowOpacity: Float {
        get {
            return self.layer.shadowOpacity
        }
        set {
            self.layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return self.layer.shadowRadius
        }
        set {
            self.layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable var shadowOffser: CGSize {
        get {
            return self.layer.shadowOffset
        }
        set {
            self.layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            if let color = self.layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            guard let color = newValue else {
                self.layer.borderColor = nil
                return
            }
            self.layer.borderColor = color.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    
    func roundCorners() {
        let dimension = min(self.bounds.size.height, self.bounds.size.width)
        self.cornerRadius = dimension * 0.5
    }
    
}

extension UILabel {
    
    @objc dynamic var fontName:String? {
        set {
            if let name = newValue {
                self.font = UIFont(name: name, size: self.font.pointSize)
            }
        }
        get {
            return self.font.fontName
        }
    }
}

extension UISearchBar {
    
    func applyKrangStyle() {
        self.searchBarStyle = .default
        self.backgroundColor = UIColor.clear
        self.backgroundImage = UIImage()
        self.isTranslucent = true
        self.barTintColor = UIColor.darkBackground
        self.tintColor = UIColor.white
    }
}
